# Comuh — Plataforma de Comunidades

API REST + interface web para gestão de comunidades, com
análise de sentimento básica.

## Status

- [x] Backend (Rails 8.1 API-only) com os 8 endpoints da API
- [x] Modelos de dados (`User`, `Community`, `Message`, `Reaction`) com
      migrations, constraints e índices
- [x] Análise de sentimento (palavras-chave)
- [x] Autenticação mínima por username (JWT, sem senha)
- [x] Frontend (Next.js + TypeScript + Tailwind)
- [x] Seeds (via chamadas HTTP à própria API)
- [x] Testes automatizados (RSpec, 100% de cobertura de linhas)
- [ ] Deploy

## Stack e por que escolhi cada peça

### Backend: Ruby on Rails 8.1 

## Gems

- **`pg`** — driver do Postgres
- **`httparty`** — cliente HTTP usado só no `db/seeds.rb`. Já utilizei a mesma em outros projetos.
- **`jwt`** — autenticação mínima para responder requisições e identificar o usuário. Simples e muito utilizada
- **`rspec-rails` + `factory_bot_rails` + `simplecov`** — framework de teste,
  geração de dados de teste sem fixture estática, e medição de cobertura. Familiaridade e gems populares.
- **`brakeman`** e **`rubocop-rails-omakase`** — análise estática de
  segurança e linter, ambos exigidos pelo checklist do teste.
- **`dotenv-rails`** e **`byebug`** — byebug ao invés do debugger por familiaridade também.

### Banco de dados: PostgreSQL 17 (via Docker Compose)

Preferencial do teste, além de ser um banco muito completo: um dos requisitos é lidar
corretamente com reações concorrentes (dois cliques "ao mesmo tempo" não podem
gerar duas reações iguais), e resolvi isso com uma constraint `UNIQUE` de
verdade no banco — somando a validação da aplicação pra esse tipo de validação.
O Postgres só roda em container (`docker-compose.yml`); o
Rails e o Next rodam direto na máquina, sem Docker, pra manter o ciclo de
desenvolvimento rápido. Também fui motivado por já ter muita experiência com o postgres.

### Frontend: Next.js (App Router) + TypeScript + Tailwind

- **Next.js** App Router e "server-side rendering"
- **TypeScript** — evitar erros em runtime e prefiro trabalhar com types.
- **Tailwind CSS** — facilitar responsividade e agilizar desenvolvimento.
- fetch nativo, pois estava construindo uma aplicação pequena, aliado
   aos hooks tem um desempenho satisfatório.

## Como rodar localmente

Pré-requisitos: Docker, Ruby 3.4.4 (uso `rbenv`), Node 24+.

1. Suba o Postgres:

   ```bash
   docker compose up -d db
   ```

2. Configure e rode o backend:

   ```bash
   cd backend
   cp .env.example .env
   bundle install
   bin/rails db:setup
   bin/rails server
   ```

   A API sobe em `http://localhost:3000`.

3. Em outro terminal, configure e rode o frontend:

   ```bash
   cd frontend
   cp .env.example .env.local
   npm install
   npm run dev
   ```

   A interface sobe em `http://localhost:3001`.

4. (Opcional) Popule o banco com dados de exemplo — precisa que o backend esteja
   rodando, porque o script fala com a API via HTTP:

   ```bash
   cd backend
   bin/rails db:seed
   ```

   Gera 3-5 comunidades, 50 usuários, 1000 mensagens (70% posts / 30%
   comentários) e reações em ~80% das mensagens.

Cada pasta (`backend/`, `frontend/`) tem seu próprio `.env.example`
documentando as variáveis necessárias — nenhuma delas tem segredo real, são
só valores padrão de desenvolvimento local.

## Testes

```bash
cd backend
bundle exec rspec
```
