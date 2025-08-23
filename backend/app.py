from flask_cors import CORS
import os
from flask import Flask, request, jsonify, send_file
import mysql.connector
import json
import subprocess

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return mysql.connector.connect(
        host="db",
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE")
    )

@app.route('/list', methods=['GET'])
def list_students():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM students")
    rows = cursor.fetchall()
    cursor.close(); conn.close()
    return jsonify(rows)

@app.route('/add', methods=['POST'])
def add_student():
    data = request.json
    name = data.get('name')
    department = data.get('department')
    student_number = data.get('student_number')
    if not name or not department or not student_number:
        return jsonify({'error': 'Missing fields'}), 400
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO students (name, department, student_number) VALUES (%s, %s, %s)",
        (name, department, student_number)
    )
    conn.commit()
    cursor.close(); conn.close()
    return jsonify({'message': 'Student added successfully'})

@app.route('/students/<int:id>', methods=['DELETE'])
def delete_student(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM students WHERE id = %s", (id,))
    conn.commit()
    cursor.close(); conn.close()
    return jsonify({'message': 'Deleted'})

@app.route('/backup', methods=['GET'])
def backup():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM students")
    data = cursor.fetchall()
    cursor.close(); conn.close()
    with open('backup.json', 'w') as f:
        json.dump(data, f)
    return send_file('backup.json', as_attachment=True)

@app.route('/restore', methods=['POST'])
def restore():
    file = request.files['file']
    data = json.load(file)
    conn = get_db_connection()
    cursor = conn.cursor()
    for s in data:
        cursor.execute(
            "INSERT INTO students (name, department, student_number) VALUES (%s, %s, %s)",
            (s['name'], s['department'], s['student_number'])
        )
    conn.commit()
    cursor.close(); conn.close()
    return jsonify({'message': 'Restore completed'})

@app.route('/update/<int:id>', methods=['PUT'])
def update_student(id):
    data = request.json
    name = data.get('name')
    department = data.get('department')
    student_number = data.get('student_number')
    if not name or not department or not student_number:
        return jsonify({'error': 'Missing fields'}), 400
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "UPDATE students SET name = %s, department = %s, student_number = %s WHERE id = %s",
        (name, department, student_number, id)
    )
    conn.commit()
    cursor.close(); conn.close()
    return jsonify({'message': 'Student updated successfully'})

@app.route('/read/<int:id>', methods=['GET'])
def read_student(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM students WHERE id = %s", (id,))
    row = cursor.fetchone()
    cursor.close(); conn.close()
    return jsonify(row) if row else (jsonify({'error': 'Student not found'}), 404)

@app.route('/sql-backup', methods=['GET'])
def sql_backup():
    db = os.getenv("MYSQL_DATABASE")
    user = os.getenv("MYSQL_USER")
    pw = os.getenv("MYSQL_PASSWORD")
    cmd = f"mysqldump -h db -u {user} -p{pw} {db} > backup.sql"
    r = subprocess.run(cmd, shell=True, executable='/bin/bash')
    if r.returncode != 0: return jsonify({'error':'Backup failed'}), 500
    return send_file('backup.sql', as_attachment=True)

@app.route('/sql-restore', methods=['POST'])
def sql_restore():
    file = request.files['file']; file.save('restore.sql')
    db = os.getenv("MYSQL_DATABASE")
    user = os.getenv("MYSQL_USER")
    pw = os.getenv("MYSQL_PASSWORD")
    cmd = f"mysql -h db -u {user} -p{pw} {db} < restore.sql"
    r = subprocess.run(cmd, shell=True, executable='/bin/bash')
    if r.returncode != 0: return jsonify({'error':'Restore failed'}), 500
    return jsonify({'message':'SQL restore completed'})

@app.route('/health')
def health(): return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)