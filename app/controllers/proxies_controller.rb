class ProxiesController < ApplicationController
    def create
        new_proxy = Proxy.create(proxy_body: params['proxy_body'], port: params['port'].to_i, proxy_pass: params['password'],
        username: params['username'])
        render json: {"proxy": new_proxy}, status: 200
    end

    def index
        all_proxies = Proxy.all
        render json: {"proxy": all_proxies}, status: 200
    end

    def delete 
        Proxy.where(id: params["proxies_ids"]).destroy_all
        render json: {"message": "Proxies deleted"}, status: 200
    end
end
