# PXL 3-Tier Web Application Sample App

This is a sample 3-tier web application that consists of a frontend, backend, and a MySQL database.

## Overview

- **Frontend:** Angular 12
- **Backend:** Node.js + Express + Sequelize
- **Database:** MySQL with a `todo` database

## Frontend

The frontend is built using **Angular 12**.

### API Configuration

The API URL is configured in `/frontend/environments/environment.prod.ts`. This value is set dynamically using the `APIURL` argument in `docker-compose.yml`.

The **multi-stage Dockerfile** uses this value before the build process.

## Backend

The backend is built using **Node.js**, **Express**, and **Sequelize**.

### Features

- A `/health` endpoint is available for health checks.
- Image carousel URLs are stored in `/backend/data/carrousel.json`.

## Database

The application uses **MySQL** as its primary database. A database named `todo` **must be present before launch**.

### Alternative Database Support

Sequelize supports multiple database management systems, including:

- MariaDB
- PostgreSQL
- Microsoft SQL Server (MSSQL)
- SQLite

For more details, refer to the [Sequelize documentation](https://sequelize.org/master/manual/getting-started.html#connecting-to-a-database).

## Setup

### Prerequisites

- Ensure that a MySQL database named `todo` exists.
  - If using Docker, the `init.sql` file will create this database automatically.
- Verify that the environment variables in `compose.yml` are correctly set:
  - `APIURL` → should point to your API.
  - `DBURL`, `DBUSER`, `DBPASSWORD`, `DBDATABASE`, `DBPORT` → should match your MySQL instance configuration.

### Deployment

Run the following command to build and start the application:

```sh
docker compose build && docker compose up
```

This will start the frontend, backend, and database services.
