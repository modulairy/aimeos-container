# Aimeos Webshop Docker Container

This Docker container is prepared to run the Aimeos Webshop. Aimeos is a modular PHP e-commerce solution for e-commerce applications.

## Usage

You can build and run your Docker container by following the steps below:

1. **Build Docker Image:**

   ```bash
   docker build -t aimeos-webshop:latest .
   ```
2. **Create and Run Docker Container:**

   ```bash
   docker run -p 8080:80 aimeos-webshop:latest
   ```
3. **View in Browser:**
   Visit `http://localhost:8080` in your browser to access the Aimeos Webshop.

## Environmental Variables

To customize the behavior of this container, you can use the environmental variables listed below. For detailed configurations, you can also refer to the [Aimeos Webshop Documentation](https://aimeos.org/docs/latest/).

- `APP_ENV`: Application environment (default: `local`).
- `APP_NAME`: Application name (default: `Aimeos`).

## MySQL Connection

Aimeos Webshop uses MySQL database. You can specify MySQL connection information using the following environmental variables:

- `DB_CONNECTION`: Database connection type (default: `mysql`).
- `DB_HOST`: MySQL server address.
- `DB_PORT`: MySQL server port (default: `3306`).
- `DB_DATABASE`: Database name.
- `DB_USERNAME`: Database username.
- `DB_PASSWORD`: Database password.

## License

This Docker container is licensed under the [MIT License](LICENSE). You can check the license file for more information.
