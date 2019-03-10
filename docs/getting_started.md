# Getting started

Hi, contributor!\
EDIT: Or hi, future version of me that got stuck and questions everything!

This document aims to explain the basic structure and inner workings of Murderers, so that new contributors easily know where to start looking.
Also, it gives reasons about *why* everything exists the way it does (or at least it tries to).

This document is divided into the following sub-documents:

* The theoretical part
  * [**Data model**](data_model.md): Covers which entities exist in the context of a game.
  * [**A murderous graph**](murderous_graph.md): Covers how the data change over time and how the operations affect it.
* The practical part / [**Architecture**](architecture.md): Covers the upper-level file architecture as well as the architecture of Murderers itself (which services and frameworks are used, what's the front-end, back-end, who talks to whom etc.).
  * [**Firestore**](firestore.md): Covers how the [data model](data_model.md) is mapped into Firestore's collections and documents.
  * [**Cloud Functions**](cloud_functions.md): Covers which Cloud Functions exist and what they do.
  * [**Authentication**](authentication.md): Covers the whole authentication process.
  * [**Cloud Messaging**](cloud_messaging.md): Covers how the different aspects of the Firebase Cloud Messaging platform are leveraged for notifying users.
