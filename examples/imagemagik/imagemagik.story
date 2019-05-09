# Image Minipluation
when http server listen method:'post' path:'/upload' as req
    dest = '/uploads/{awesome id}.png'
    req write content:{location:dest}
    req finish
    img = imagemagik resize image:req.files['image'] width:50 height:50
    aws/s3 put content:img :dest
