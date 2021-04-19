class ProxiesController < ApplicationController
    def create
        new_proxy = Proxy.create(proxy_body: params['proxy_body'], port: params['port'].to_i, password: params['password'],
        username: params['username'])
        render json: {"proxy": new_proxy}
    end

    def index
        all_proxies = Proxy.all
        render json: {"proxy": all_proxies}
    end

    def delete 
        Proxy.where(id: params["proxies_ids"]).destroy_all
        render json: {"message": "Proxies deleted"}
    end
end
