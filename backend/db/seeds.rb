# Popula o banco fazendo chamadas HTTP reais para a própria API.
# Por isso o servidor Rails precisa estar rodando antes de executar `bin/rails db:seed`.
#
# Comunidades são a única exceção: como não existe endpoint de criação de
# community na API, elas são criadas direto via ActiveRecord.

API_BASE_URL = ENV.fetch("SEED_API_URL", "http://localhost:3000")

COMMUNITIES = [
  { name: "Rubyists", description: "Comunidade de desenvolvedores Ruby e Rails" },
  { name: "Frontend Devs", description: "Discussões sobre React, Vue e o ecossistema JS" },
  { name: "DevOps Brasil", description: "Infraestrutura, CI/CD e cloud" },
  { name: "Data Science BR", description: "Machine learning, dados e estatística" }
].freeze

TOTAL_USERS = 50
TOTAL_POSTS = 700
TOTAL_COMMENTS = 300
TOTAL_IPS = 20
REACTION_COVERAGE = 0.8

USERNAMES = (1..TOTAL_USERS).map { |i| "user#{i}" }.freeze
IPS = (1..TOTAL_IPS).map { |i| "10.0.#{i}.#{rand(1..254)}" }.freeze

CONTENT_SAMPLES = [
  "Que ideia excelente, adorei essa comunidade!",
  "Achei incrível o que vocês compartilharam hoje.",
  "Muito bom esse conteúdo, parabéns pelo trabalho.",
  "Isso foi péssimo, esperava muito mais.",
  "Horrível, não gostei nada dessa abordagem.",
  "Ruim demais, não recomendo.",
  "Alguém sabe como configurar isso direito?",
  "Compartilhando esse link que encontrei ontem.",
  "Interessante, vou testar aqui e depois conto o resultado.",
  "Dia comum por aqui, nada de especial pra reportar."
].freeze

def wait_for_server!
  HTTParty.get("#{API_BASE_URL}/up", timeout: 3)
rescue Errno::ECONNREFUSED, Net::OpenTimeout
  abort <<~MESSAGE
    Não consegui conectar em #{API_BASE_URL}.
    Rode `bin/rails server` em outro terminal antes de executar os seeds.
  MESSAGE
end

def post_json(path, body)
  HTTParty.post(
    "#{API_BASE_URL}#{path}",
    headers: { "Content-Type" => "application/json" },
    body: body.to_json
  )
end

def seed_communities
  puts "== Criando comunidades =="

  COMMUNITIES.map do |attrs|
    Community.find_or_create_by!(name: attrs[:name]) { |community| community.description = attrs[:description] }
  end
end

def seed_posts(communities)
  puts "== Criando #{TOTAL_POSTS} posts via API =="

  message_ids_by_community = Hash.new { |hash, key| hash[key] = [] }

  TOTAL_POSTS.times do |i|
    community = communities.sample

    response = post_json("/api/v1/messages", {
      username: USERNAMES.sample,
      community_id: community.id,
      content: CONTENT_SAMPLES.sample,
      user_ip: IPS.sample
    })

    message_ids_by_community[community.id] << response["id"] if response.success?
    print "." if (i % 50).zero?
  end

  puts
  message_ids_by_community
end

def seed_comments(message_ids_by_community)
  puts "== Criando #{TOTAL_COMMENTS} comentários via API =="

  TOTAL_COMMENTS.times do |i|
    community_id, message_ids = message_ids_by_community.to_a.sample
    parent_id = message_ids&.sample
    next unless parent_id

    post_json("/api/v1/messages", {
      username: USERNAMES.sample,
      community_id: community_id,
      content: CONTENT_SAMPLES.sample,
      user_ip: IPS.sample,
      parent_message_id: parent_id
    })

    print "." if (i % 50).zero?
  end

  puts
end

def seed_reactions
  puts "== Reagindo a #{(REACTION_COVERAGE * 100).round}% das mensagens via API =="

  user_ids = User.pluck(:id)
  message_ids = Message.pluck(:id).sample((Message.count * REACTION_COVERAGE).round)

  message_ids.each_with_index do |message_id, i|
    Reaction::REACTION_TYPES.sample(rand(1..3)).each do |reaction_type|
      post_json("/api/v1/reactions", {
        message_id: message_id,
        user_id: user_ids.sample,
        reaction_type: reaction_type
      })
    end

    print "." if (i % 50).zero?
  end

  puts
end

def print_summary
  puts "== Resumo =="
  puts "Comunidades: #{Community.count}"
  puts "Usuários: #{User.count}"
  puts "Mensagens: #{Message.count}"
  puts "Reações: #{Reaction.count}"
end

wait_for_server!
communities = seed_communities
message_ids_by_community = seed_posts(communities)
seed_comments(message_ids_by_community)
seed_reactions
print_summary
