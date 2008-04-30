module Admin::UsersHelper
  def role_names_of(user)
    h(user.roles.collect(&:name).join(', '))
  end
  
  def state_name_of(user)
    case user.state
      when 'pending'    then 'Wartend'
      when 'active'     then 'Aktiv'
      when 'suspended'  then 'Gesperrt'
      when 'deleted'    then 'Gelöscht'
    end
  end
end
