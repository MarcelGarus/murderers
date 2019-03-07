# Architecture

The top-level folders are pretty self-explanatory:

* `backend`: Contains the back-end code.
* `app`: Contains the front-end code (the app).
* `store`: Contains resources for the store entry.
* `docs`: Contains documentation.

This is how everything is organized:

![architecture](images/architecture.png)

## Why did I decide to use ...?

* **Firebase**: It's an all-in-one mobile backend solution providing many useful services.
* [**Firestore**](firestore.md): It's the fastest and most reliable cloud storage (at least on GCP). Also, I had prior experience working with it.
* **Firebase Cloud Functions**: It naturally comes along with Firebase. And again, I had some prior experience working with it.
* **Firebase Cloud Messaging**: It comes with Firebase.
* **Flutter**: Is a true multi-platform front end experience. According to my prior experiences, it's wonderful to work with.
