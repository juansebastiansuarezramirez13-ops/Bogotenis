from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
from decimal import Decimal
import os

app = Flask(__name__)
app.secret_key = "cambia-esta-clave-por-una-segura"  # necesario para sesiones

IMAGENES_DIR = os.path.join(app.root_path, "static", "img")
EXTENSIONES_PERMITIDAS = {"png", "jpg", "jpeg", "webp", "gif"}

# ---------------------------------------------------------------
# Configuración de conexión con XAMPP / MySQL
# ---------------------------------------------------------------
app.config["MYSQL_HOST"] = "localhost"
app.config["MYSQL_USER"] = "root"
app.config["MYSQL_PASSWORD"] = ""
app.config["MYSQL_DB"] = "tienda_bogotenis"
app.config["MYSQL_CURSORCLASS"] = "DictCursor"  # para trabajar con filas como diccionarios

mysql = MySQL(app)


# =================================================================
# UTILIDADES / DECORADORES DE SEGURIDAD
# =================================================================
def login_requerido(vista):
    @wraps(vista)
    def wrapper(*args, **kwargs):
        if "usuario_id" not in session:
            flash("Debes iniciar sesión para continuar.", "warning")
            return redirect(url_for("login"))
        return vista(*args, **kwargs)
    return wrapper


def admin_requerido(vista):
    @wraps(vista)
    def wrapper(*args, **kwargs):
        if session.get("rol") != "admin":
            flash("No tienes permisos para acceder al panel administrativo.", "danger")
            return redirect(url_for("index"))
        return vista(*args, **kwargs)
    return wrapper


def obtener_productos(solo_ofertas=False, categoria_id=None):
    """Trae los productos junto con sus variantes de color y tallas."""
    cursor = mysql.connection.cursor()

    query = """
        SELECT p.id, p.marca, p.nombre, p.precio, p.stock, p.categoria_id,
               p.en_oferta, p.estado
        FROM productos p
        WHERE p.estado != 'oculto'
    """
    params = []
    if solo_ofertas:
        query += " AND p.en_oferta = 1"
    if categoria_id:
        query += " AND p.categoria_id = %s"
        params.append(categoria_id)
    query += " ORDER BY p.id"

    cursor.execute(query, params)
    productos = cursor.fetchall()

    for producto in productos:
        cursor.execute(
            "SELECT color_nombre, color_code, imagen FROM variantes_producto "
            "WHERE producto_id = %s ORDER BY orden",
            (producto["id"],)
        )
        producto["variantes"] = cursor.fetchall()

        cursor.execute(
            "SELECT talla FROM tallas_producto WHERE producto_id = %s ORDER BY talla",
            (producto["id"],)
        )
        producto["tallas"] = [t["talla"] for t in cursor.fetchall()]
        producto["precio"] = float(producto["precio"])

    cursor.close()
    return productos


# =================================================================
# CATÁLOGO PÚBLICO
# =================================================================
@app.route("/")
def index():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id, nombre FROM categorias ORDER BY id")
    categorias = cursor.fetchall()
    cursor.close()

    productos = obtener_productos()
    return render_template("index.html", productos=productos, categorias=categorias)


@app.route("/ofertas")
def ofertas():
    productos = obtener_productos(solo_ofertas=True)
    return render_template("ofertas.html", productos=productos)


# =================================================================
# AUTENTICACIÓN (registro, login, logout)
# =================================================================
@app.route("/registro", methods=["GET", "POST"])
def registro():
    if request.method == "POST":
        nombre = request.form["nombre"].strip()
        correo = request.form["correo"].strip().lower()
        contrasena = request.form["contrasena"]

        if not nombre or not correo or not contrasena:
            flash("Todos los campos son obligatorios.", "danger")
            return redirect(url_for("registro"))

        cursor = mysql.connection.cursor()
        cursor.execute("SELECT id FROM usuarios WHERE correo = %s", (correo,))
        if cursor.fetchone():
            cursor.close()
            flash("Ese correo ya está registrado.", "danger")
            return redirect(url_for("registro"))

        hash_contrasena = generate_password_hash(contrasena)
        cursor.execute(
            "INSERT INTO usuarios (nombre, correo, contrasena_hash, rol) "
            "VALUES (%s, %s, %s, 'cliente')",
            (nombre, correo, hash_contrasena)
        )
        mysql.connection.commit()
        cursor.close()

        flash("Cuenta creada correctamente. Ya puedes iniciar sesión.", "success")
        return redirect(url_for("login"))

    return render_template("registro.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        correo = request.form["correo"].strip().lower()
        contrasena = request.form["contrasena"]

        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM usuarios WHERE correo = %s", (correo,))
        usuario = cursor.fetchone()
        cursor.close()

        if usuario and check_password_hash(usuario["contrasena_hash"], contrasena):
            session["usuario_id"] = usuario["id"]
            session["nombre"] = usuario["nombre"]
            session["rol"] = usuario["rol"]
            flash(f"¡Bienvenido, {usuario['nombre']}!", "success")
            if usuario["rol"] == "admin":
                return redirect(url_for("admin_dashboard"))
            return redirect(url_for("index"))

        flash("Correo o contraseña incorrectos.", "danger")
        return redirect(url_for("login"))

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    flash("Sesión cerrada correctamente.", "info")
    return redirect(url_for("index"))


# =================================================================
# CHECKOUT: crea el pedido en la base de datos
# =================================================================
@app.route("/pedido/crear", methods=["POST"])
@login_requerido
def crear_pedido():
    """Recibe el carrito (JSON) desde script.js y lo guarda en la BD."""
    datos = request.get_json()
    items = datos.get("items", [])
    if not items:
        return jsonify({"error": "El carrito está vacío"}), 400

    metodo_pago = datos.get("metodo_pago", "WhatsApp")
    pago_datos = datos.get("pago_datos", {})

    # Construir referencia de pago segura (sin datos sensibles)
    referencia = ""
    if metodo_pago in ("visa", "mastercard"):
        num = pago_datos.get("tarjeta_numero", "")
        referencia = "****" + num[-4:] if len(num) >= 4 else ""
    elif metodo_pago == "pse":
        referencia = pago_datos.get("banco", "") + " - CC " + pago_datos.get("doc_numero", "")
    elif metodo_pago == "efecty":
        referencia = pago_datos.get("doc_tipo", "") + " " + pago_datos.get("doc_numero", "")
    elif metodo_pago == "nequi":
        referencia = "Cel: " + pago_datos.get("celular", "")
    elif metodo_pago == "daviplata":
        referencia = "Cel: " + pago_datos.get("celular", "")

    cursor = mysql.connection.cursor()
    try:
        total = sum(Decimal(str(item["price"])) for item in items)

        cursor.execute(
            "INSERT INTO pedidos (usuario_id, total, estado, direccion_entrega, metodo_pago) "
            "VALUES (%s, %s, 'confirmado', %s, %s)",
            (session["usuario_id"], total, referencia, metodo_pago.upper())
        )
        pedido_id = cursor.lastrowid

        for item in items:
            cursor.execute(
                "INSERT INTO detalle_pedido "
                "(pedido_id, producto_id, talla, color_nombre, cantidad, precio_unitario, subtotal) "
                "VALUES (%s, %s, %s, %s, 1, %s, %s)",
                (pedido_id, item["product_id"], item["size"], item.get("color_name", ""),
                 item["price"], item["price"])
            )
            cursor.execute(
                "UPDATE productos SET stock = stock - 1 "
                "WHERE id = %s AND stock > 0",
                (item["product_id"],)
            )

        mysql.connection.commit()
    except Exception as error:
        mysql.connection.rollback()
        cursor.close()
        return jsonify({"error": "No se pudo registrar el pedido"}), 500

    cursor.close()
    return jsonify({"ok": True, "pedido_id": pedido_id})


# =================================================================
# PANEL ADMINISTRATIVO
# =================================================================
@app.route("/admin")
@login_requerido
@admin_requerido
def admin_dashboard():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT COUNT(*) AS total FROM productos")
    total_productos = cursor.fetchone()["total"]
    cursor.execute("SELECT COUNT(*) AS total FROM usuarios WHERE rol = 'cliente'")
    total_clientes = cursor.fetchone()["total"]
    cursor.execute("SELECT COUNT(*) AS total FROM pedidos")
    total_pedidos = cursor.fetchone()["total"]
    cursor.execute("SELECT COALESCE(SUM(total),0) AS ventas FROM pedidos WHERE estado != 'cancelado'")
    ventas = cursor.fetchone()["ventas"]
    cursor.execute(
        "SELECT p.id, p.nombre, p.stock FROM productos p WHERE p.stock <= 3 ORDER BY p.stock"
    )
    bajo_inventario = cursor.fetchall()
    cursor.close()

    return render_template(
        "admin/dashboard.html",
        total_productos=total_productos,
        total_clientes=total_clientes,
        total_pedidos=total_pedidos,
        ventas=ventas,
        bajo_inventario=bajo_inventario,
    )


@app.route("/admin/productos")
@login_requerido
@admin_requerido
def admin_productos():
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT p.*, c.nombre AS categoria_nombre
        FROM productos p
        JOIN categorias c ON c.id = p.categoria_id
        ORDER BY p.id
    """)
    productos = cursor.fetchall()
    cursor.close()
    return render_template("admin/productos.html", productos=productos)


@app.route("/admin/productos/nuevo", methods=["GET", "POST"])
@login_requerido
@admin_requerido
def admin_producto_nuevo():
    cursor = mysql.connection.cursor()

    if request.method == "POST":
        marca = request.form["marca"].strip()
        nombre = request.form["nombre"].strip()
        precio = request.form["precio"]
        stock = request.form["stock"]
        categoria_id = request.form["categoria_id"]
        en_oferta = 1 if request.form.get("en_oferta") else 0

        if not marca or not nombre or float(precio) < 0 or int(stock) < 0:
            flash("Revisa los datos del producto: no se permiten precios o stock negativos.", "danger")
            return redirect(url_for("admin_producto_nuevo"))

        cursor.execute(
            "INSERT INTO productos (marca, nombre, precio, stock, categoria_id, en_oferta) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (marca, nombre, precio, stock, categoria_id, en_oferta)
        )
        producto_id = cursor.lastrowid

        # variante de color principal
        color_nombre = request.form.get("color_nombre", "Único")
        color_code = request.form.get("color_code", "#cccccc")
        imagen = request.form.get("imagen", "shoe1-1.png")
        cursor.execute(
            "INSERT INTO variantes_producto (producto_id, color_nombre, color_code, imagen, orden) "
            "VALUES (%s, %s, %s, %s, 0)",
            (producto_id, color_nombre, color_code, imagen)
        )

        # tallas separadas por coma, ej: 38,39,40
        tallas = [t.strip() for t in request.form.get("tallas", "").split(",") if t.strip()]
        for talla in tallas:
            cursor.execute(
                "INSERT INTO tallas_producto (producto_id, talla) VALUES (%s, %s)",
                (producto_id, talla)
            )

        mysql.connection.commit()
        cursor.close()
        flash("Producto creado correctamente.", "success")
        return redirect(url_for("admin_productos"))

    cursor.execute("SELECT id, nombre FROM categorias ORDER BY nombre")
    categorias = cursor.fetchall()
    cursor.close()
    return render_template("admin/producto_form.html", categorias=categorias, producto=None)


@app.route("/admin/productos/<int:producto_id>/editar", methods=["GET", "POST"])
@login_requerido
@admin_requerido
def admin_producto_editar(producto_id):
    cursor = mysql.connection.cursor()

    if request.method == "POST":
        marca = request.form["marca"].strip()
        nombre = request.form["nombre"].strip()
        precio = request.form["precio"]
        stock = request.form["stock"]
        categoria_id = request.form["categoria_id"]
        en_oferta = 1 if request.form.get("en_oferta") else 0
        estado = request.form.get("estado", "disponible")

        if not marca or not nombre or float(precio) < 0 or int(stock) < 0:
            flash("Revisa los datos del producto: no se permiten precios o stock negativos.", "danger")
            return redirect(url_for("admin_producto_editar", producto_id=producto_id))

        cursor.execute(
            "UPDATE productos SET marca=%s, nombre=%s, precio=%s, stock=%s, "
            "categoria_id=%s, en_oferta=%s, estado=%s WHERE id=%s",
            (marca, nombre, precio, stock, categoria_id, en_oferta, estado, producto_id)
        )
        mysql.connection.commit()
        cursor.close()
        flash("Producto actualizado.", "success")
        return redirect(url_for("admin_productos"))

    cursor.execute("SELECT * FROM productos WHERE id = %s", (producto_id,))
    producto = cursor.fetchone()
    cursor.execute("SELECT id, nombre FROM categorias ORDER BY nombre")
    categorias = cursor.fetchall()
    cursor.close()

    if not producto:
        flash("Producto no encontrado.", "danger")
        return redirect(url_for("admin_productos"))

    return render_template("admin/producto_form.html", categorias=categorias, producto=producto)


@app.route("/admin/productos/<int:producto_id>/eliminar", methods=["POST"])
@login_requerido
@admin_requerido
def admin_producto_eliminar(producto_id):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM productos WHERE id = %s", (producto_id,))
    mysql.connection.commit()
    cursor.close()
    flash("Producto eliminado.", "info")
    return redirect(url_for("admin_productos"))


@app.route("/admin/pedidos")
@login_requerido
@admin_requerido
def admin_pedidos():
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT ped.id, ped.fecha, ped.total, ped.estado, u.nombre AS cliente
        FROM pedidos ped
        JOIN usuarios u ON u.id = ped.usuario_id
        ORDER BY ped.fecha DESC
    """)
    pedidos = cursor.fetchall()
    cursor.close()
    return render_template("admin/pedidos.html", pedidos=pedidos)


@app.route("/admin/usuarios")
@login_requerido
@admin_requerido
def admin_usuarios():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id, nombre, correo, rol, fecha_registro, estado FROM usuarios ORDER BY id")
    usuarios = cursor.fetchall()
    cursor.close()
    return render_template("admin/usuarios.html", usuarios=usuarios)


# =================================================================
# NEWSLETTER
# =================================================================
@app.route("/newsletter", methods=["POST"])
def newsletter():
    correo = (request.form.get("correo") or "").strip().lower()
    if not correo or "@" not in correo or "." not in correo:
        return jsonify({"ok": False, "mensaje": "Ingresa un correo electronico valido."}), 400
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id FROM suscriptores WHERE correo = %s", (correo,))
    if cursor.fetchone():
        cursor.close()
        return jsonify({"ok": True, "mensaje": "Ya estas suscrito, gracias!"})
    cursor.execute("INSERT INTO suscriptores (correo) VALUES (%s)", (correo,))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"ok": True, "mensaje": "Gracias por suscribirte!"})


@app.route("/admin/suscriptores")
@login_requerido
@admin_requerido
def admin_suscriptores():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id, correo, fecha_registro FROM suscriptores ORDER BY fecha_registro DESC")
    suscriptores = cursor.fetchall()
    cursor.close()
    suscriptores_json = [
        {
            "id": s["id"],
            "correo": s["correo"],
            "fecha": s["fecha_registro"].strftime("%d/%m/%Y %H:%M") if s["fecha_registro"] else "",
        }
        for s in suscriptores
    ]
    return render_template("admin/suscriptores.html", suscriptores=suscriptores, suscriptores_json=suscriptores_json)


# =================================================================
# GESTOR DE IMAGENES
# =================================================================
@app.route("/admin/imagenes")
@login_requerido
@admin_requerido
def admin_imagenes():
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT v.id AS variante_id, v.producto_id, v.color_nombre, v.color_code,
               v.imagen, v.orden, p.marca, p.nombre AS producto_nombre
        FROM variantes_producto v
        JOIN productos p ON p.id = v.producto_id
        ORDER BY p.id, v.orden
    """)
    variantes = cursor.fetchall()
    cursor.close()
    for v in variantes:
        v["existe"] = os.path.exists(os.path.join(IMAGENES_DIR, v["imagen"]))
    return render_template("admin/imagenes.html", variantes=variantes)


@app.route("/admin/imagenes/subir", methods=["POST"])
@login_requerido
@admin_requerido
def admin_imagen_subir():
    variante_id = request.form.get("variante_id")
    archivo = request.files.get("archivo")
    if not variante_id or not archivo or archivo.filename == "":
        flash("Selecciona una imagen valida.", "danger")
        return redirect(url_for("admin_imagenes"))

    extension = archivo.filename.rsplit(".", 1)[-1].lower() if "." in archivo.filename else ""
    if extension not in EXTENSIONES_PERMITIDAS:
        flash("Formato no permitido. Usa png, jpg, jpeg, webp o gif.", "danger")
        return redirect(url_for("admin_imagenes"))

    cursor = mysql.connection.cursor()
    cursor.execute("SELECT imagen FROM variantes_producto WHERE id = %s", (variante_id,))
    fila = cursor.fetchone()
    if not fila:
        cursor.close()
        flash("Variante no encontrada.", "danger")
        return redirect(url_for("admin_imagenes"))

    base = os.path.splitext(fila["imagen"])[0]
    nuevo_nombre = base + "." + extension
    os.makedirs(IMAGENES_DIR, exist_ok=True)
    archivo.save(os.path.join(IMAGENES_DIR, nuevo_nombre))

    cursor.execute("UPDATE variantes_producto SET imagen = %s WHERE id = %s", (nuevo_nombre, variante_id))
    mysql.connection.commit()
    cursor.close()
    flash("Imagen guardada como " + nuevo_nombre, "success")
    return redirect(url_for("admin_imagenes"))


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
