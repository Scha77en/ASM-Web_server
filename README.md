# 🕸️ Minimal HTTP Web Server in x86_64 Assembly

This project is a **simple HTTP/1.0 web server written entirely in x86_64 assembly**, using **Intel syntax** and direct Linux syscalls.

It supports:

- `GET` requests to serve static files (e.g. `.txt`, `.html`)
- `POST` requests to save file contents
- Forking for concurrent connections
- Pure syscall usage — no libc, no runtime

---

## 🔧 Assembling & Linking

```bash
as web_server.s -o web_server.o
ld web_server.o -o server
```

> The code is written in Intel syntax using the as (GNU Assembler) toolchain. If you prefer nasm, adapt syntax accordingly.

---

## 🚀 Running the Server

```bash
sudo ./server
```

Or with syscall tracing:

```bash
sudo strace -f -e trace=network,read,write,open,close ./server
```

The server listens on **port 8000** by default.

---

## 📁 Preparing Files for Testing

Before testing, create files in the same directory:

```bash
echo "This is index.html" > index.html
echo "Test file for GET" > foo.txt
```

### Simple GET

```bash
curl http://localhost:8000/index.html
```

### Simple POST

```bash
curl -X POST http://localhost:8000/submit.txt -d "Hello World"
```

After a POST request, check the created file:

```bash
cat submit.txt
```

---

---

## 📚 Learning Focus

This project was created to:

- Learn Linux syscalls (e.g. `socket`, `bind`, `accept`, `read`, `write`, `open`, `fork`)
- Understand HTTP request structure (minimal parsing)
- Build a working web server from scratch in assembly

---

## ⚙️ System Requirements

- Linux (tested on Kali and Ubuntu)
- `as` and `ld` (GNU Binutils)
- root privileges to bind port and trace syscalls

---

## ✅ Features Recap

- Raw socket handling
- Manual file I/O
- Process creation for each connection
- Simple and educational

---

## 🧠 Author Notes

Made for fun and learning, showcasing the power of pure assembly with no libraries. Diving into low level CPU and Memory, manipulating the stack and playing with registers was fun and insightful