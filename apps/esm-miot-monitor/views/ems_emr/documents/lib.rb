
module EsmMiotMonitor

def radio_string this, name, options={}
  return inline(this,'documents/_render_field', :this=>this, :name=>name, :options=>options, :type=>'radio_string')
end

def check_string this, name, options={}
  return inline(this,'documents/_render_field', :this=>this, :name=>name, :options=>options, :type=>'check_string')
end

def select_string this, name, options={}
  return inline(this,'documents/_render_field', :this=>this, :name=>name, :options=>options, :type=>'select_string')
end

def text_string this, name, options={}
  return inline(this,'documents/_render_field', :this=>this, :name=>name, :options=>options, :type=>'text_string')
end

def date_string this, name, options={}
  return inline(this,'documents/_render_field', :this=>this, :name=>name, :options=>options, :type=>'date_string')
end

def time_string this, name, options={}
  return inline(this,'documents/_render_field', :this=>this, :name=>name, :options=>options, :type=>'time_string')
end


end
