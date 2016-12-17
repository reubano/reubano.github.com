curl https://api.github.com/users/nerevu/repos?per_page=100 | jq . > data/nerevu-repos.json
curl https://api.github.com/users/reubano/repos?per_page=100 | jq . > data/reubano-repos.json

curl -d "method=flickr.photosets.getList" \
     -d "api_key=76ca8dd185de46fdd0d24c24f6e4d0ea" \
     -d "user_id=47144176@N00" \
     -d "format=json" \
     -d "nojsoncallback=1" \
    https://api.flickr.com/services/rest \
    | jq . > data/galleries.json

curl -d "method=flickr.photosets.getPhotos" \
     -d "api_key=76ca8dd185de46fdd0d24c24f6e4d0ea" \
     -d "user_id=47144176@N00" \
     -d "extras=description,date_upload,date_taken,original_format,last_update,geo,tags,o_dims,views,media,path_alias,url_sq,url_t,url_s,url_m,url_o,url_q,url_n,url_e,url_z,url_c,url_l,url_h,url_k" \
     -d "format=json" \
     -d "nojsoncallback=1" \
     -d "photoset_id=72157623891823165" \
     https://api.flickr.com/services/rest \
     | jq . > data/travel-gallery.json

curl -d "method=flickr.photosets.getPhotos" \
     -d "api_key=76ca8dd185de46fdd0d24c24f6e4d0ea" \
     -d "user_id=47144176@N00" \
     -d "extras=description,date_upload,date_taken,original_format,o_dims,media,url_o" \
     -d "format=json" \
     -d "nojsoncallback=1" \
     -d "photoset_id=72157676561966910" \
     https://api.flickr.com/services/rest \
     | jq . > data/post-images-gallery.json

curl -d "method=flickr.photosets.getPhotos" \
     -d "api_key=76ca8dd185de46fdd0d24c24f6e4d0ea" \
     -d "user_id=47144176@N00" \
     -d "extras=description,date_upload,date_taken,original_format,last_update,geo,tags,o_dims,views,media,path_alias,url_sq,url_t,url_s,url_m,url_o,url_q,url_n,url_e,url_z,url_c,url_l,url_h,url_k" \
     -d "format=json" \
     -d "nojsoncallback=1" \
     -d "photoset_id=72157623888340443" \
     https://api.flickr.com/services/rest \
     | jq . > data/misc-gallery.json

curl -d "method=flickr.photosets.getPhotos" \
     -d "api_key=76ca8dd185de46fdd0d24c24f6e4d0ea" \
     -d "user_id=47144176@N00" \
     -d "extras=description,date_upload,date_taken,original_format,last_update,geo,tags,o_dims,views,media,path_alias,url_sq,url_t,url_s,url_m,url_o,url_q,url_n,url_e,url_z,url_c,url_l,url_h,url_k" \
     -d "format=json" \
     -d "nojsoncallback=1" \
     -d "photoset_id=72157623678762653" \
     https://api.flickr.com/services/rest \
     | jq . > data/arusha-gallery.json

curl -d "method=flickr.photosets.getPhotos" \
     -d "api_key=76ca8dd185de46fdd0d24c24f6e4d0ea" \
     -d "user_id=47144176@N00" \
     -d "extras=description,date_upload,date_taken,original_format,last_update,geo,tags,o_dims,views,media,path_alias,url_sq,url_t,url_s,url_m,url_o,url_q,url_n,url_e,url_z,url_c,url_l,url_h,url_k" \
     -d "format=json" \
     -d "nojsoncallback=1" \
     -d "photoset_id=72157663394312666" \
     https://api.flickr.com/services/rest \
     | jq . > data/nahla-gallery.json
