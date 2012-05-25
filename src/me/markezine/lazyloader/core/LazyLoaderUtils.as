package me.markezine.lazyloader.core
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	

	internal class LazyLoaderUtils
	{
		private static var _baseURL:String;
		
		internal static function getItemType(url:String):String{
			var dot_splited:Array = url.split(".");
			var extension:String = dot_splited[dot_splited.length-1];
			switch(extension){
				case ItemType.BITMAP:
				case ItemType.FLASH:
				case ItemType.TEXT:
				case ItemType.BINARY:
				case ItemType.AUDIO:
				case ItemType.VIDEO:
					return extension;
				case "swf":
					return ItemType.FLASH;
				case "jpg":
				case "jpeg":
				case "png":
				case "gif":
					return ItemType.BITMAP;
					break;
				
				case "flv":
				case "f4v":
				case "mp4":
				case "m4a":
				case "mov":
				case "mp4v":
				case "3gp":
				case "3g2":
					return ItemType.VIDEO;
					
				case "mp3":
					return ItemType.AUDIO;
			}
			return ItemType.TEXT;
		}
		
		internal static function getRequest(request:Object):URLRequest{
			var _request:URLRequest;
			if(request is URLRequest){
				_request = URLRequest(request);
			}else{
				_request = new URLRequest(String(request));
			}
			return _request;
		}
		
		internal static function getAbsoluteUrl(url:String):String{
			return url.indexOf("://") >-1 ? url : baseURL + url;
		}
		
		internal static function get baseURL():String{
			if(_baseURL) return _baseURL;
			_baseURL = ExternalInterface.available ? ExternalInterface.call("window.location.href.toString") : "";
			if(_baseURL){
				_baseURL = _baseURL.indexOf("#") > - 1 ? _baseURL.substr(0, _baseURL.indexOf("#")): baseURL;
				_baseURL = _baseURL.substr(0, _baseURL.lastIndexOf("/")+1);
			}
			return _baseURL;
		}
		
		internal static function createLoader(type:String):ICustomLoader{
			switch(type){
				case ItemType.BITMAP:
				case ItemType.FLASH:
					return new CustomLoader();
					break;
				
				case ItemType.VIDEO:
					return new CustomNetStream();
					break;
				
				case ItemType.AUDIO:
					return new CustomSound();
					break;
			}
			return new CustomURLLoader();
		}
		
		internal static function createUniqueId():String{
			var uniqueId:String = "";
			var pattern:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
			while(uniqueId.length<32) uniqueId+= pattern.charAt(Math.floor(Math.random()*pattern.length)); 
			return uniqueId;
		}
		
		internal static function removeFromVector(vector:Vector.<String>, value:String):void{
			if(vector.indexOf(value) > -1 ) vector.splice(vector.indexOf(value), 1);
		}
		
		internal static function addToVector(vector:Vector.<String>, value:String):void{
			if(vector.indexOf(value) == -1) vector.push(value); 
		}
	}
}