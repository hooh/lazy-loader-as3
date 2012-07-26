/**
 * Licensed under the MIT License and Creative Commons 3.0 BY-SA
 * 
 * Copyright (c) 2011 The LazyLoader Team
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS CREATIVE COMMONS PUBLIC 
 * LICENSE ("CCPL" OR "LICENSE"). THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. 
 * ANY USE OF THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
 * PROHIBITED.
 * BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO BE BOUND BY THE 
 * TERMS OF THIS LICENSE. TO THE EXTENT THIS LICENSE MAY BE CONSIDERED TO BE A CONTRACT, THE 
 * LICENSOR GRANTS YOU THE RIGHTS CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH 
 * TERMS AND CONDITIONS.
 * 
 * http://creativecommons.org/licenses/by-sa/3.0/legalcode
 *  
 * http://code.google.com/p/lazy-loader-as3
 * 
 * @author João Paulo Marquesini (markezine)
 * 
 */

package me.markezine.lazyloader.core
{
	import flash.external.ExternalInterface;
	import flash.net.URLLoaderDataFormat;
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
					
				case "3ds":
					return ItemType.BINARY;
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
				
				case ItemType.BINARY:
					var urlLoader:CustomURLLoader = new CustomURLLoader();
					urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					return urlLoader;
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