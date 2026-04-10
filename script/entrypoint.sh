#!/usr/bin/env sh
set -eu

cd /var/www/html

if [ ! -f .env ]; then
  cp .env.example .env
fi

php -r "
\$env = file_get_contents('.env');

function setEnvValue(\$content, \$key, \$value) {
    \$pattern = '/^' . preg_quote(\$key, '/') . '=.*/m';
    \$line = \$key . '=' . \$value;
    if (preg_match(\$pattern, \$content)) {
        return preg_replace(\$pattern, \$line, \$content);
    }
    return \$content . PHP_EOL . \$line . PHP_EOL;
}

\$vars = [
    'APP_NAME' => getenv('APP_NAME') ?: 'AimeosApp',
    'APP_ENV' => getenv('APP_ENV') ?: 'local',
    'APP_DEBUG' => getenv('APP_DEBUG') ?: 'true',
    'APP_URL' => getenv('APP_URL') ?: 'http://localhost:8080',
    'DB_CONNECTION' => getenv('DB_CONNECTION') ?: 'mysql',
    'DB_HOST' => getenv('DB_HOST') ?: 'db',
    'DB_PORT' => getenv('DB_PORT') ?: '3306',
    'DB_DATABASE' => getenv('DB_DATABASE') ?: 'aimeos',
    'DB_USERNAME' => getenv('DB_USERNAME') ?: 'aimeos',
    'DB_PASSWORD' => getenv('DB_PASSWORD') ?: 'aimeos123',
    'CACHE_STORE' => getenv('CACHE_STORE') ?: 'file',
    'SESSION_DRIVER' => getenv('SESSION_DRIVER') ?: 'file',
    'QUEUE_CONNECTION' => getenv('QUEUE_CONNECTION') ?: 'database',
];

foreach (\$vars as \$key => \$value) {
    \$env = setEnvValue(\$env, \$key, \$value);
}

file_put_contents('.env', \$env);
"

if ! grep -q '^APP_KEY=base64:' .env; then
  php artisan key:generate --force
fi

until nc -z "${DB_HOST:-db}" "${DB_PORT:-3306}"; do
  echo "Waiting for database..."
  sleep 2
done

php artisan migrate --force
php artisan aimeos:setup --force || true

exec "$@"
