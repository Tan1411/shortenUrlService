# URL Shortening Service

A robust and secure URL shortening service built with Ruby on Rails. This service provides URL encoding/decoding functionality with advanced anti-abuse measures and collision-resistant algorithms.

## Features

- **Secure URL Shortening**: Generates unique, anti-guessing short codes using Sqids
- **Collision Resistant**: Advanced encoding algorithm prevents code collisions
- **DDoS Protection**: Built-in rate limiting and IP blocking via Rack::Attack
- **RESTful API**: Simple encode/decode endpoints
- **Comprehensive Testing**: Full test coverage with RSpec

## Ruby Version

- **Ruby**: 3.3.4
- **Rails**: 7.1.3

## Core Architecture

### Encoding/Decoding Mechanism

The service uses **Sqids** (Secure Quick IDs) library to generate unique short codes. The encoding process works as follows:

1. **Input Parameters**: 
   - `length`: Length of the original URL
   - `id`: Database record ID of the URL

2. **Encoding Process**:
   ```ruby
   # Combines URL length and ID to create unique input
   encoded_token = SQIDS.encode([length, id])
   ```

3. **Why This Approach**:
   - **Uniqueness**: Combining length + ID ensures no two URLs produce the same code
   - **Anti-Guessing**: Custom alphabet and minimum length make codes unpredictable
   - **Collision Prevention**: Mathematical impossibility of collisions with this input combination

## Key Gems

### 1. Sqids
- **Purpose**: Secure ID generation and encoding
- **Configuration**: Custom alphabet and minimum length
- **Security**: Prevents ID enumeration attacks

### 2. Rack::Attack
- **Purpose**: DDoS protection and rate limiting
- **Features**: 
  - IP-based throttling
  - Automatic fail2ban-style blocking
  - Configurable response headers
  - Real-time monitoring and logging

## API Endpoints

- `POST /encode` - Encode a URL to short code
- `POST /decode` - Decode a short code back to original URL

## Testing

The service includes comprehensive unit tests covering:

1. **`spec/models/url_spec.rb`** - URL model validation tests
2. **`spec/services/shorten_url_service_spec.rb`** - Core encoding/decoding logic tests
3. **`spec/requests/shorten_controller_spec.rb`** - API endpoint integration tests

## Security Considerations

### Potential Attack Vectors

1. **DDoS Attacks**: Mitigated by Rack::Attack rate limiting
2. **ID Enumeration**: Prevented by Sqids encoding with URL length
3. **Brute Force**: Custom alphabet and minimum length make guessing impractical
4. **Collision Attacks**: Mathematically prevented by unique input combination

### Protection Measures

- Rate limiting (200 req/5min per IP)
- Automatic IP banning for abuse
- Custom alphabet obfuscation
- Input validation and sanitization

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Git

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Tan1411/shortenUrlService.git
   cd shortenUrlService
   ```
2. **setup environment variables**:
   ```bash
   cp .env.example .env
   ```
3. **Build Docker image**:
   ```bash
   docker compose build
   ```

4. **Start the services**:
   ```bash
   docker compose up -d
   ```

### Running Tests

```bash
docker compose exec app bundle exec rspec
```

## Demo Deployment

The service is deployed and available for testing at:
**https://shorten-url-service.onrender.com/**

### Available Actions:
- **Encode**: `POST /encode` - Convert long URLs to short codes
- **Decode**: `POST /decode` - Convert short codes back to original URLs

## Usage Example

### Local Development
```bash
# Encode a URL
curl -X POST http://localhost:3000/encode \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.example.com"}'

# Decode a short code
curl -X POST http://localhost:3000/decode \
  -H "Content-Type: application/json" \
  -d '{"url": "http://localhost:3000/7ljHKI"}'
```

### Production Demo
```bash
# Encode a URL
curl -X POST https://shorten-url-service.onrender.com/encode \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.example.com"}'

# Decode a short code
curl -X POST https://shorten-url-service.onrender.com/decode \
  -H "Content-Type: application/json" \
  -d '{"url": "https://shorten-url-service.onrender.com/7ljHKI"}'
```
