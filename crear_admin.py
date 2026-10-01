"""
Ejecuta este script UNA sola vez después de crear la base de datos
(schema.sql) para registrar el usuario administrador con una
contraseña correctamente cifrada.

Uso:
    python crear_admin.py
"""
import MySQLdb
from werkzeug.security import generate_password_hash

NOMBRE = "Administrador Bogotenis"
CORREO = "admin@bogotenis.com"
CONTRASENA = "admin123"   # cámbiala después de tu primer inicio de sesión

conexion = MySQLdb.connect(
    host="localhost",
    user="root",
    passwd="",
    db="tienda_bogotenis"
)
cursor = conexion.cursor()

cursor.execute("SELECT id FROM usuarios WHERE correo = %s", (CORREO,))
if cursor.fetchone():
    print("El usuario administrador ya existe.")
else:
    hash_contrasena = generate_password_hash(CONTRASENA)
    cursor.execute(
        "INSERT INTO usuarios (nombre, correo, contrasena_hash, rol) VALUES (%s, %s, %s, 'admin')",
        (NOMBRE, CORREO, hash_contrasena)
    )
    conexion.commit()
    print("Usuario administrador creado:")
    print(f"  Correo: {CORREO}")
    print(f"  Contraseña: {CONTRASENA}")

cursor.close()
conexion.close()
