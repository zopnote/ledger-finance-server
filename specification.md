# HTTP interface specification

``localhost:port/api`` - root, returns simple http page \
``localhost:port/api/status`` - receives the status of the http server ([specification]()) ([source]()) \
``localhost:port/api/send-invoice/`` - POST an invoice json string ([specification]()) ([source]()) \
``localhost:port/api/retrieve-invoices/`` - receives invoices in a time window ([specification]()) ([source]()) \
``localhost:port/api/manage-item/`` - Adds or removes an item of the orderable item list ([specification]()) ([source]()) \
``localhost:port/api/retrieve-items/`` - receives a list of all orderable items ([specification]()) ([source]()) \
