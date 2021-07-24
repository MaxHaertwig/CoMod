# Diploma Thesis

This repository contains all the work related to [Max Härtwig](mailto:max.haertwig@mailbox.tu-dresden.de)'s diploma thesis with the title **Mobile Modeling with Real-Time Collaboration Support**. It is based on a [prior analysis](https://git-st.inf.tu-dresden.de/stgroup/student-projects/2021/aft-max-haertwig) of the topic.

It is organized into different sections:

- [Client](./client): the client application
- [Server](./server): the server backend
- [Thesis](./thesis): the written part
- [Schema](./schema): the schema of the client's data model
- [Protocol](./protocol): the communication protocol between client and server
- [Yjs Pack](./yjs-pack): bundles Yjs using webpack

## Setup

Initialize the git submodules (if you haven't done so during cloning):

```bash
git submodule update --init
```

Run the setup script:

```bash
./setup.sh
```
