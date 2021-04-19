class RenamePasswordproxiesToProxies < ActiveRecord::Migration[5.2]
  def change
    rename_column :proxies, :password, :proxy_pass
  end
end
