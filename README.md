# BOGOTENIS — Tienda Flask + XAMPP + MySQL

Proyecto Flask que conecta el catálogo, el login/registro y el panel
administrativo de BOGOTENIS con una base de datos MySQL en XAMPP.

## 1. Preparar XAMPP
Abre **XAMPP Control Panel** y enciende:
```
Apache  -> Start
MySQL   -> Start
```
Luego entra a phpMyAdmin: http://localhost/phpmyadmin

## 2. Crear la base de datos
En la pestaña **SQL** de phpMyAdmin, pega y ejecuta todo el contenido
del archivo `schema.sql`. Esto crea la base `tienda_bogotenis` con las
tablas `usuarios`, `categorias`, `productos`, `variantes_producto`,
`tallas_producto`, `pedidos` y `detalle_pedido`, además de los 13
productos de ejemplo (con sus colores, imágenes y tallas).

## 3. Crear la carpeta del proyecto
Ya está organizada así:
```
bogotenis/
├── app.py
├── crear_admin.py
├── schema.sql
├── requirements.txt
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── ofertas.html
│   ├── login.html
│   ├── registro.html
│   └── admin/
│       ├── base_admin.html
│       ├── dashboard.html
│       ├── productos.html
│       ├── producto_form.html
│       ├── pedidos.html
│       └── usuarios.html
└── static/
    ├── css/styles.css
    ├── js/script.js
    └── img/ (shoe1-1.png, shoe2-1.png, ...)
```

## 4. Crear y activar el entorno virtual
```
python -m venv venv
```
Si PowerShell bloquea la activación, ejecuta una sola vez:
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Activa el entorno:
```
venv\Scripts\Activate.ps1
```

## 5. Instalar dependencias
```
pip install -r requirements.txt
```

## 6. Crear el usuario administrador
Con MySQL de XAMPP encendido y la base ya creada:
```
python crear_admin.py
```
Esto crea el usuario:
- Correo: `admin@bogotenis.com`
- Contraseña: `admin123`

## 7. Ejecutar la aplicación
```
python app.py
```
Abre en el navegador: http://127.0.0.1:5000

## 8. Probar el flujo completo
- **Catálogo:** en `/` verás los productos que vienen de MySQL, filtrables por categoría.
- **Ofertas:** en `/ofertas` se listan los productos con `en_oferta = 1` (-20%).
- **Registro de cliente:** `/registro` crea un usuario con rol `cliente` y contraseña con hash.
- **Login:** `/login` valida credenciales contra la tabla `usuarios`.
- **Compra:** al finalizar el pedido desde el carrito, se guarda en `pedidos` y
  `detalle_pedido`, se descuenta el `stock` y luego se abre WhatsApp con el resumen.
- **Panel admin:** al iniciar sesión como `admin@bogotenis.com` puedes ir a `/admin`
  para ver el resumen, gestionar productos (crear, editar, eliminar), ver pedidos
  y ver usuarios registrados.

## 9. Verificar en phpMyAdmin
Revisa las tablas `usuarios`, `pedidos` y `detalle_pedido` dentro de
`tienda_bogotenis` para confirmar que los registros, compras e inventario
se están actualizando correctamente.

## Seguridad implementada
- Contraseñas guardadas con hash (`werkzeug.security`), nunca en texto plano.
- Rutas `/admin/*` protegidas con decoradores que verifican sesión activa y rol.
- Validaciones de precio y stock no negativos tanto en frontend como backend.
- El total del pedido se calcula en el servidor, no se recibe desde el cliente.
- El descuento de inventario ocurre solo al confirmar el pedido.
