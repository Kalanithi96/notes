# Notes

My first Flutter app 

User Login system using Firebase Auth.

Each note has a title and a text.
A verified user can view, create, update, delete and share a note.

The Authentication process is abstracted using Auth Service
The CRUD operations are abstracted using CRUD Service

The storage is currently set in Cloud.
To use a local SQLite database to store the notes, you can replace `CrudService.firebase()` with `CrudService.sqlite()`.

---WIP---

Credits:\
Guidance: [Vandad](https://www.youtube.com/watch?v=VPvVD8t02U8&t=111559s&pp=ygUQZmx1dHRlciB0dXRvcmlhbA%3D%3D)\
App Icon - [Stockio.com](https://www.stockio.com/)
