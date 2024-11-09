FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /home/user

# Copy requirements first to leverage Docker cache
COPY requirements.txt /home/user/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . /home/user/

# Expose the Shiny port
EXPOSE 8000

# Command to run the Shiny app
CMD ["shiny", "run", "/home/user/app.py", "--host", "0.0.0.0", "--port", "8000"]
