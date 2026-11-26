# Reporte — Sesión 13: Supply Chain Security

- Rama: feature/supply-chain-13 -> main
- Archivos clave: docker/Dockerfile.s13 y .github/workflows/supply-chain.yml (el Dockerfile estuvo en la raíz; se movió a `docker/` al ordenar el repo)

## 1. Registros en el workflow
- Listo el job pipeline en sesion13-supply-chain para hacer el build y subir la imagen a ghcr.io.
-  Syft para generar el SBOM y dejarlo guardado como artefacto
-  Cosign para firmar la imagen, adjuntar la atestación del SBOM y validar la imagen apuntando directo a ${{ env.DIGREF }}.

## 2. Problemas y como se soluciono
- **Ruta del Dockerfile:** se movio Dockerfile.s13 a la raíz del repo porque no lo estaba encontrando al momento del build.
- **Formato YAML:** se corrigio la indentación de steps y de los pasos dentro de .github/workflows/supply-chain.yml para que no tirara error de sintaxis.
- **Prueba negativa y vuelta atrás:** se probo un rato con alpine:latest en el paso de verificar firma para asegurar de que el pipeline lo bloqueara, y después se volvio a dejar ${{ env.DIGREF }}.

*El workflow sesion13-supply-chain corrió completo y quedó en verde, con el archivo SBOM desde artefactos y su captura del fallo en cosign verify como evidencia*
