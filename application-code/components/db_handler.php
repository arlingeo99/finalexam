<?php

$endpoint = "main-db.chhlmagweyt0.us-east-1.rds.amazonaws.com";
$username = "admin";
$password = "zc49OdtssIjcBh18fR4X5";
$database = "techco";


function validateFormData($data)
{
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

function setupDatabase()
{
    global $endpoint, $username, $password, $database;

    // Connect to MySQL server
    $conn = new mysqli($endpoint, $username, $password);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Create database if not exists
    $createDbSql = "CREATE DATABASE IF NOT EXISTS techco";
    if ($conn->query($createDbSql) !== TRUE) {
        die("Error creating database: " . $conn->error);
    }

    // Use the created database
    $conn->select_db($database);

    // Create table if not exists
    $createTableSql = "CREATE TABLE IF NOT EXISTS contacts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255),
        email VARCHAR(255),
        service_type VARCHAR(255),
        phone_number VARCHAR(20),
        message TEXT
    )";

    if ($conn->query($createTableSql) !== TRUE) {
        die("Error creating table: " . $conn->error);
    }

    // Close the database connection
    $conn->close();
}

function handleFormData($name, $email, $serviceType, $phoneNumber, $message)
{
    global $endpoint, $username, $password, $database;
    
    // Connect to your MySQL RDS database
    $conn = new mysqli($endpoint, $username, $password, $database);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $name = validateFormData($name);
    $email = validateFormData($email);
    $serviceType = validateFormData($serviceType);
    $phoneNumber = validateFormData($phoneNumber);
    $message = validateFormData($message);

    // SQL query to insert data into the database
    $sql = "INSERT INTO contacts (name, email, service_type, phone_number, message) 
            VALUES ('$name', '$email', '$serviceType', '$phoneNumber', '$message')";

    if ($conn->query($sql) === TRUE) {
        return true;
    } else {
        return false;
    }

    // Close the database connection
    $conn->close();
}

// Call the setupDatabase function to ensure the database and table exist
setupDatabase()
?>
