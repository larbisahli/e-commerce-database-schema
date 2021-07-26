## <h3 align="center">DropGala Database Configuration</h3>

### Database Diagram:

<p align="center"><img src="db-diagram.png" width="80%"/></p>

Website : https://dropgala.com

### pgadmin ssh:

check: [how-to-connect-pgadmin4-to-db-through-ssh-tunnel-with-public-key-authentication](https://medium.com/3-elm-erlang-elixir/faq-how-to-connect-pgadmin4-to-db-through-ssh-tunnel-with-public-key-authentication-b351750c20be)

Nginx-keepalive: [Here](https://www.digitalocean.com/community/tutorials/how-to-set-up-highly-available-web-servers-with-keepalived-and-floating-ips-on-ubuntu-14-04)

### environment variables

Setting an environment variable for a droplet is a little more complicated than for an app running on the app platform.

Follow these steps to set environment variables on a Linux droplet:

SSH into your droplet. If you’re not sure how to do that, see here
Once connected, run the following command to set your environment variable:

```bash
$ export YOUR_VARIABLE_KEY=<your-variable-value>
```

## Let's Ecnrypt

SSL valid until: Thu, 21 Oct 2021 02:33:48

check: [Here](https://www.digitalocean.com/community/tutorials/how-to-secure-a-containerized-node-js-application-with-nginx-let-s-encrypt-and-docker-compose)

Logrotate: [Here](https://www.digitalocean.com/community/tutorials/how-to-manage-logfiles-with-logrotate-on-ubuntu-16-04)

ENV : [Here](https://docs.greatexpectations.io/en/0.11.6/how_to_guides/configuring_data_contexts/how_to_use_a_yaml_file_or_environment_variables_to_populate_credentials.html)

```bash
$ tail -f /var/log/cron.log
```

## Logs:

Let's Encript renew Logs

```bash
$ tail -f /var/log/cron.log
```
