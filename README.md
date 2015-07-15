##ESP8266 Webserver with AJAX GPIO Toggle

State of the GPIO is not synchronized realtime with the user interface. It is in sync only when the page is loaded. Therefore multiple clients toggling the GPIO will not see the actual state of the GPIO. It was intended to be operated only by one HTTP client.

