# vuln-apps
Collection of Vulnerable apps

- WebGoat
- DVWA
- OWASP Bricks
- Mutillidae
- commix
- More to come.

Usage
=====

```
docker pull raj77in/vuln-apps
docker run -d -p 80:80 -p 8080:8080 raj77in/vuln-apps
```

After this you can visit index page at:
http://localhost/

Build from Docker file:
```docker build -t raj77in/vuln-apps .```

