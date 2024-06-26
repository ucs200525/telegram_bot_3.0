# Stage 1: Build Python environment
FROM python:3.9-slim AS python-builder

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

COPY bot.py /app

# Stage 2: Build Node.js environment
FROM node:14-slim AS node-builder

# Set working directory
WORKDIR /app

# Install necessary system dependencies for Node.js
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libicu-dev \
    libjpeg62-turbo \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpng16-16 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json from current directory to /app in container
COPY package.json package-lock.json /app/

# Install Node.js dependencies
RUN npm install --production

# Stage 3: Final stage with runtime environment
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy Python dependencies from the first stage
COPY --from=python-builder /usr/local/ /usr/local/

# Copy Node.js dependencies from the second stage
COPY --from=node-builder /app/app

# Copy Node.js scripts
COPY image2.js /app/image2.js
COPY newProj.js /app/newProj.js

# Set permissions for Node.js scripts
RUN chmod +x /app/image2.js /app/newProj.js

# Command to run the bot (adjust as per your setup)
CMD ["python", "bot.py"]
