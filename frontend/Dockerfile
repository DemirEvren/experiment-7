FROM node:18-alpine AS build
WORKDIR /usr/src/app

ARG APIURL
ENV APIURL ${APIURL}

COPY . .

RUN echo "export const environment = {production: true, apiurl: '${APIURL}'};" > /usr/src/app/src/environments/environment.prod.ts

RUN npm install
RUN npm run build --configuration=production

FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/app/dist/frontend/ /usr/share/nginx/html

# added extra: for the source map this can be deleted for production after my experiment
# RUN find /usr/share/nginx/html -name "*.map" -delete