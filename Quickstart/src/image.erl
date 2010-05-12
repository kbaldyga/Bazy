-module(image).
-include_lib("wx/include/wx.hrl").
-export([resize/4]).

%% downloaded from http://meeteoric.blogspot.com/2009/10/how-to-convert-transcode-images-in.html
resize(ImgIn,ImgOut,Width,Height) ->
	wx:new(),
	RefImg = wxImage:new(ImgIn, [{type, ?wxBITMAP_TYPE_ANY}]),
	ThumbImg = wxImage:scale(RefImg, Width, Height, [{quality, ?wxIMAGE_QUALITY_HIGH}]),
	true = wxImage:saveFile(ThumbImg, ImgOut, ?wxBITMAP_TYPE_JPEG),
	ok = wxImage:destroy(ThumbImg),
	ok = wxImage:destroy(RefImg),
	ok = wx:destroy().
