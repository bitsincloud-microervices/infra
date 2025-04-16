FROM node:14

# Create app directory
WORKDIR /app

# Clone the Konga repository
RUN git clone https://github.com/pantsel/konga.git /app

# Checkout the last known good version
RUN git checkout 1c8cdeaa4ae63f691f50fc024c32a579c4fcb4e9

# Update and install dependencies
RUN npm install sails@1.2.4 sails-postgresql@1.0.0 pg@8.7.3

# Install other dependencies
RUN npm install

# Expose ports
EXPOSE 1337

# Start Konga
CMD ["node", "/app/app.js"]
