# 🚀 Rider Performance Hub

Repositorio central de scripts SQL, Notebooks y análisis del equipo de datos.

---

## 📂 Estructura del Repositorio

* `sql_queries/`: Consultas SQL optimizadas para BigQuery organizadas por dominio.
* `notebooks/`: Jupyter Notebooks (.ipynb) de Python para análisis complejos.
* `documentation/`: Guías de uso y diccionario de datos.

---

## 📌 Índice de Scripts Principales

| Dominio | Nombre del Script | Descripción | Autor | Link |
| :--- | :--- | :--- | :--- | :--- |
| **Rider Performance** | `rider_tickets_comments.sql` | Unifica la metadata de tickets/formularios con los comentarios limpios cargados por los riders. | @nicolasrestrepo-hash | [Ver Script](sql_queries/rider_performance/rider_tickets_comments.sql) |

---

## 🛠️ Cómo Contribuir
1. Crea tu script dentro de la carpeta correspondiente (`sql_queries/` o `notebooks/`).
2. Agrega una fila en la tabla del índice con el enlace a tu archivo.
3. Asegúrate de comentar los parámetros variables (como `DECLARE dInf DATE`).
