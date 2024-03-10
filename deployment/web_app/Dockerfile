# Use an official Python runtime as a parent image. Need specific versions to improve stability
FROM python:3.11.6

#LABEL maintainer="djangoapp.com"
# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run app.py when the container launches
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Command to initialize the database and run the application !!give execute permissions chmod +x entrypoint.sh
# CMD ["./entrypoint.sh"]
