## Integrantes

**Profesor:** 
 - Sebastián Salazar Molina  
**Integrantes:** 
 - Héctor Arturo Araya Pérez
 - Carlos Araya
 - Ian Battistoni

## Descripción

Como las nuevas tecnologías y el desarrollo de la inteligencia artificial crecen día a día, este proyecto se creó para ayudar a los equipos a llenar y descargar datasets de manera más amigable. Esta aplicación permite a los usuarios autenticarse con Google, cargar imágenes a datasets específicos y descargar datasets para su análisis y uso en modelos de aprendizaje automático.

## Características

- Cargar imágenes a datasets específicos.
- Descargar datasets completos.
- Interfaz amigable y fácil de usar.

## Páginas de la Aplicación

### Home Page (home_page.dart)

- Al cargar esta página, se realiza una solicitud GET a una API desarrollada en NestJS. Esta API devuelve los nombres de los datasets disponibles.
- Los nombres de los datasets se presentan como botones clickeables. Cada botón tiene dos funciones: descargar el dataset como un archivo ZIP y navegar a la página de subfolders.
- La opción de descarga comprime el dataset seleccionado en un archivo ZIP, haciéndolo más liviano para la descarga.
- Al hacer clic en un dataset, el usuario es dirigido a la página de subfolders, donde puede explorar más a fondo el contenido del dataset.

### Upload Image Page (upload_image_page.dart)

- Esta página permite a los usuarios subir imágenes a un dataset específico.
- Los usuarios pueden seleccionar el dataset y la etiqueta (subfolder) para la imagen.
- Si el dataset o el subfolder no existen, la aplicación los crea automáticamente y permite agregar una descripción del nuevo dataset o subfolder.
- Esta funcionalidad es esencial para mantener la organización y categorización de los datos de manera dinámica y sencilla.

### Subfolders Page (subfolders_page.dart)

- En esta página, se muestra la descripción del dataset seleccionado y se listan todos los archivos y subfolders que contiene.
- Se realiza una solicitud POST a la API de NestJS con el nombre del dataset para obtener los subfolders correspondientes.
- Los subfolders son clickeables, permitiendo a los usuarios explorar su contenido.
- Al hacer clic en un subfolder, se navega a la página de imágenes.

### Images Page (images_page.dart)

- Esta página muestra todas las imágenes contenidas en un subfolder específico.
- Se realiza una solicitud POST a la API de NestJS con el nombre del dataset y el subfolder para obtener todas las imágenes.
- Las imágenes se presentan de manera que los usuarios puedan visualizarlas cómodamente.

## Instalación

1. Clona el repositorio:
   ```sh
   git clone <url-del-repositorio>

## Instalación de dependencias

   ```sh
   flutter pub get
