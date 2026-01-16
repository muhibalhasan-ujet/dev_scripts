#tenants = %w[zdcomuhibalhasan sfcomuhibalhasan kustomermuhibalhasan]
tenants = %w[sfcomuhib]

users = [
  {
    email: "muhib.hasan@ujet.cx",
    first_name: "Muhib",
    last_name: "Admin",
    roles: [:admin, :agent]
  },
  {
    email: "muhib.hasan+1@ujet.cx",
    first_name: "Muhib+1",
    last_name: "Manager",
    roles: [:manager]
  }
]

# Add +2, +3, +4 users (all agents)
(2..4).each do |i|
  users << {
    email: "muhib.hasan+#{i}@ujet.cx",
    first_name: "Muhib+#{i}",
    last_name: "Agent",
    roles: [:agent]
  }
end

PASSWORD = "123456Ab!@"

def update_menu_settings(menu, menu_type, default_email)
  menu.settings.where(lang: 'en').update_all(name: menu.name, enabled: true)

  case menu_type
  when 'mobile'
    menu.email_settings.where(lang: 'en').update_all(enabled: true, email: default_email)
    menu.chat_settings.where(lang: 'en').update_all(enabled: true)
    menu.voice_call_settings.where(lang: 'en').update_all(instant_enabled: true, schedule_enabled: true)
    menu.video_call_settings.where(lang: 'en').update_all(enabled: true)
  when 'web'
    menu.email_settings.where(lang: 'en').update_all(enabled: true, email: default_email)
    menu.chat_settings.where(lang: 'en').update_all(enabled: true)
    menu.voice_call_settings.where(lang: 'en').update_all(instant_enabled: true, schedule_enabled: true)
  when 'ivr'
    menu.voice_call_settings.where(lang: 'en').update_all(instant_enabled: true, schedule_enabled: true)
  when 'sms', 'whats_app', 'amb'
    menu.chat_settings.where(lang: 'en').update_all(enabled: true)
  when 'email'
    menu.email_settings.where(lang: 'en').update_all(enabled: true, email: default_email)
  end
end

def assign_users_to_menu(menu, users)
  Menu::QueueGroup.where(menu_id: menu.id, lang: 'en').each do |group|
    users.each do |user|
      assignment = group.assignments.find_by(
        assignee: user,
        menu_id: menu.id,
        channel_type: group.channel,
        lang: 'en'
      )

      if assignment
        # Assignment already exists
      else
        group.assignments.create!(
          assignee: user,
          menu_id: menu.id,
          channel_type: group.channel,
          lang: 'en'
        )
        puts "  ✅ Assigned #{user.email} to #{menu.name} (#{CommQueue::Channel::REVERSE_MAP[group.channel]})"
      end
    end
  end
end

def create_menu(menu_class, name, menu_type, default_email, users = nil)
  menu = menu_class.find_by(name: name)
  if menu
    puts "⚠️  Menu already exists: #{name}"
  else
    menu = menu_class.create!(
      name: name,
      position: 0
    )
    puts "✅ Created #{menu_type.upcase} Menu: #{name}"
    update_menu_settings(menu, menu_type, default_email)
  end

  if users
    assign_users_to_menu(menu, users)
  else
    puts "  ℹ️  No users assigned (VA only menu)"
  end

  menu
end

def create_menus_for_tenant(created_users)
  puts "\n📋 Creating menus..."

  admin_user = created_users.find { |u| u.email == "muhib.hasan@ujet.cx" }
  plus2_user = created_users.find { |u| u.email == "muhib.hasan+2@ujet.cx" }

  # Menu types configuration
  menu_configs = [
    { class: Menu::MobileMenu, type: 'mobile', name_suffix: 'Mobile' },
    { class: Menu::IvrMenu, type: 'ivr', name_suffix: 'IVR' },
    { class: Menu::WebMenu, type: 'web', name_suffix: 'Web' },
    { class: Menu::SmsMenu, type: 'sms', name_suffix: 'SMS' },
    { class: Menu::WhatsAppMenu, type: 'whats_app', name_suffix: 'WhatsApp' },
    { class: Menu::EmailMenu, type: 'email', name_suffix: 'Email' },
    { class: Menu::AmbMenu, type: 'amb', name_suffix: 'AMB' }
  ]

  menu_configs.each do |config|
    # Create "Admin Muhib" menu with muhib.hasan@ujet.cx
    create_menu(
      config[:class],
      "Admin Muhib #{config[:name_suffix]}",
      config[:type],
      "muhib.hasan@ujet.cx",
      admin_user ? [admin_user] : nil
    )

    # Create "Muhib+2" menu with muhib.hasan+2@ujet.cx
    create_menu(
      config[:class],
      "Muhib+2 #{config[:name_suffix]}",
      config[:type],
      "muhib.hasan+2@ujet.cx",
      plus2_user ? [plus2_user] : nil
    )

    # Create VA only menu (no user assignments)
    create_menu(
      config[:class],
      "VA Only #{config[:name_suffix]}",
      config[:type],
      "muhib.hasan@ujet.cx",
      nil
    )
  end

  puts "📋 Menu creation completed"
end

def main
    tenants.each do |tenant|
    puts "\n=== Switching to tenant: #{tenant} ==="
    TenantSelect.switch!(tenant)

    created_users = []

    users.each do |attrs|
        email = attrs[:email]

        # HARD DELETE — bypass soft delete, callbacks, and default scopes
        puts "Hard-deleting any existing (including soft-deleted) user: #{email}"
        User.unscoped.where(email: email).delete_all

        # Create a fresh user
        user = User.new(
        email: email,
        first_name: attrs[:first_name],
        last_name: attrs[:last_name],
        roles: attrs[:roles],
        password: PASSWORD,
        invite_code: nil
        )

        user.save!

        AvailabilityFilter::UserFilterCreator.create_default_filter(user)

        puts "Created #{email} (roles: #{user.roles.inspect})"
        created_users << user
    end

    # Create menus and assign users
    create_menus_for_tenant(created_users)
    end
end

puts "\n=== DONE ==="


