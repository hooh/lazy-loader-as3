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
package me.markezine.lazyloader.core {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	
	
	public class LazyLoader extends EventDispatcher
	{
		private static var staticInstance:LazyLoader;
		
		private var _isLoading:Boolean=false;
		private var _isPaused:Boolean = false;
		private var _maxConnections:uint = 10;
		private var _defaultContext:LoaderContext;
		private var _useWeakReference:Boolean = false;

		private var items:Dictionary;
		private var loading:Dictionary;
		private var loaded:Dictionary;
		
		private var toBeLoaded:Vector.<String>;
		private var toGetSize:Vector.<String>;
		
		private var data:XML;
		
		private var connections:Vector.<Connection>;
		
		public function LazyLoader(singleton:Singleton):void{
			if(!singleton) throw new Error(getQualifiedClassName(this) + " is a Singleton and can't be instantiated.");
			init();
		}
		
		static private function get instance():LazyLoader{
			if(!staticInstance) staticInstance = new LazyLoader(new Singleton());
			return staticInstance;
		}
		
		static public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		static public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			instance.removeEventListener(type, listener, useCapture);
		}
			
		static public function add(request:Object, attributes:Object=null):LazyLoaderItem{
			return instance.add(request, attributes);
		}
		
		static public function remove(item:LazyLoaderItem):void{
			instance.remove(item);
		}
		
		static public function start(getSizeFirst:Boolean=false):void{
			instance.start(getSizeFirst);
		}
		
		static public function pause():void{
			instance.pause();
		}
		
		static public function stop():void{
			instance.stop();
		}
		
		static public function isLoaded(parameters:Object):Boolean{
			return instance.isLoaded(parameters);
		}
		
		public static function isLoading(parameters:Object) : Boolean {
			return instance.isLoading(parameters);
		}
		
		public static function getLazyLoaderItem(parameters:Object) : LazyLoaderItem {
			return instance.getLazyLoaderItem(parameters);
		}
		
		static public function getBitmap(parameters:Object):Bitmap{
			return instance.getBitmap(parameters);
		}
		
		static public function getBitmapData(parameters:Object):BitmapData{
			return instance.getBitmap(parameters).bitmapData;
		}
		
		static public function getSprite(parameters:Object):Sprite{
			return instance.getSprite(parameters);
		}
				
		static public function getDisplayObject(parameters:Object):DisplayObject{
			return instance.getDisplayObject(parameters);
		}
		
		static public function getLoader(parameters:Object):Loader{
			return instance.getLoader(parameters);
		}
		
		static public function getNetStream(parameters:Object):NetStream{
			return instance.getNetStream(parameters);
		}
		
		static public function getNetStreamMetadata(parameters:Object):Object{
			return instance.getNetStreamMetadata(parameters);
		}
		
		static public function getSound(parameters:Object):Sound{
			return instance.getSound(parameters);
		}
		
		static public function getMovieClip(parameters:Object):MovieClip{
			return instance.getMovieClip(parameters);
		}
		
		static public function getData(parameters:Object):String{
			return instance.getData(parameters);
		}
		
		static public function getXML(parameters:Object):XML{
			return instance.getXML(parameters);
		}
		
		static public function getByteArray(parameters:Object):ByteArray{
			return instance.getByteArray(parameters);
		}
		
		static public function get status():String{
			return instance.status;
		}
		
		static public function get maxConnections():uint{
			return instance._maxConnections;
		}
		
		static public function set maxConnections(value:uint):void{
			instance._maxConnections = Math.max(value, 1);
		}
		
		static public function get defaultContext():LoaderContext
		{
			return instance._defaultContext;
		}
		
		static public function set defaultContext(value:LoaderContext):void
		{
			instance._defaultContext = value;
		}
		
		static public function get useWeakReference():Boolean
		{
			return instance._useWeakReference;
		}
		
		static public function set useWeakReference(value:Boolean):void
		{
			instance._useWeakReference = value;
		}

		private function init():void{
			items = new Dictionary();
			loading = new Dictionary();
			loaded = new Dictionary();
			toBeLoaded = new Vector.<String>();
			connections = new Vector.<Connection>();
			data = new XML("<data></data>");
		}
		
		private function start(getSizeFirst:Boolean):void{
			_isLoading=true;
			if(getSizeFirst){
				getSizes();
				addEventListener(LazyLoaderEvent.COMPLETED_GETTING_SIZE, mainListener);
			}else{
				loadNext();
			}
		}
		
		private function pause():void{
			if(!_isLoading) return;
			_isLoading = false;
			for each(var connection:Connection in connections){
				connection.pause();
			}
		}
		
		private function stop():void{
			pause();
			
			for(var i:String in toBeLoaded){
				delete items[toBeLoaded[i]];
				delete loading[toBeLoaded[i]];
				delete loaded[toBeLoaded[i]];
			}
			
			toBeLoaded = new Vector.<String>();
		}

		private function mainListener(event : LazyLoaderEvent) : void {
			switch(event.type){
				case LazyLoaderEvent.COMPLETED_GETTING_SIZE:
					removeEventListener(LazyLoaderEvent.COMPLETED_GETTING_SIZE, mainListener);
					loadNext();
					break;
			}
		}
			
		private function add(request:Object, attributes:Object):LazyLoaderItem{
			if(!request) throw new Error("Can't add resource with empty URL.");
			var uniqueId:String = createUniqueId();
			
			if(attributes is LazyLoaderVariables) attributes = LazyLoaderVariables(attributes).toObject();
			
			var req:URLRequest;
			if(request is URLRequest){
				req = URLRequest(request);
			}else if(request is String){
				req = new URLRequest(String(request));
			}else{
				for(var i:String in request){
					var attribs:Object = {};
					for(var j:String in attributes) attribs[j] = attributes[j];
					attribs.id = String(i);
					add(request[i] is URLRequest ? URLRequest(request[i]) : String(request[i]), attribs);
				}
				return null;
			} 
			
			items[uniqueId] = loading[uniqueId] = new LazyLoaderItem(req, uniqueId, attributes);
			toBeLoaded.push(uniqueId);
			addNode(uniqueId, req.url, attributes);
			return items[uniqueId];
		}
		
		private function remove(attributes:Object):void{
			var uniqueId:String;
			if(attributes is LazyLoaderItem){
				uniqueId = LazyLoaderItem(attributes).uniqueId;
			}else{
				try{
					uniqueId = getUniqueId(attributes);
				}catch(e:Error){}
			}
			
			for each(var connection:Connection in connections){
				if(connection.item.uniqueId == uniqueId){
					connection.pause();
					connections.splice(connections.indexOf(connection),1);
				}
			}
			
			if(loaded[uniqueId]) delete loaded[uniqueId];
			if(items[uniqueId]) delete items[uniqueId];
			if(loading[uniqueId]) delete loading[uniqueId];
			
			data.file.(@lazy_loader_unique_id == uniqueId)[0].@removed = false;
			
			System.gc();
		}
		
		private function isLoaded(parameters:Object):Boolean{
			var uniqueId:String = "";
			try{
				uniqueId = getUniqueId(parameters);
			}catch(e:Error){}
			return Boolean(loaded[uniqueId]);
		}
		
		private function isLoading(parameters : Object) : Boolean {
			var uniqueId:String = "";
			try{
				uniqueId = getUniqueId(parameters);
			}catch(e:Error){}
			return Boolean(loading[uniqueId]);
		}
		
		private function getLazyLoaderItem(parameters:Object):LazyLoaderItem{
			var uniqueId:String = getUniqueId(parameters);
			if(!items[uniqueId]){
				throw new Error("Resource not added.");				
			}else{		
				return LazyLoaderItem(items[uniqueId]);
			}
		}
		
		private function getDisplayObject(parameters:Object):DisplayObject{
			var item:LazyLoaderItem = getLazyLoaderItem(parameters);
			if(!loaded[item.uniqueId]){
				throw new Error("Resource not loaded.");
			}else if(!item.content || !(item.content is DisplayObject)){
				throw new Error("Resource " + item.url + " is not a DisplayObject.");
			}else{
				if(item.useWeakReference) remove(item.uniqueId);
				return DisplayObject(item.content);
			}
		}
		
		private function getLoader(parameters:Object):Loader{
			var item:LazyLoaderItem = getLazyLoaderItem(parameters);
			if(!item.loader is Loader){
				throw new Error("Resource " + item.url + " is not a Loader.");
			}else{
				return Loader(item.loader);
			}
		}
		
		private function getBitmap(parameters:Object):Bitmap{
			var uniqueId:String = getUniqueId(parameters);
			var displayObject:DisplayObject = getDisplayObject(uniqueId);
			if(!(displayObject is Bitmap)){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a Bitmap.");
			}else{
				return Bitmap(displayObject);				
			}
		}
		
		private function getSprite(parameters:Object):Sprite{
			var uniqueId:String = getUniqueId(parameters);
			var displayObject:DisplayObject = getDisplayObject(uniqueId);
			if(!(displayObject is Sprite)){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a Sprite.");
			}else{
				return Sprite(displayObject);
			}
		}
		
		private function getMovieClip(parameters:Object):MovieClip{
			var uniqueId:String = getUniqueId(parameters);
			var displayObject:DisplayObject = getDisplayObject(uniqueId);
			if(!(displayObject is MovieClip)){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a MovieClip.");
			}else{
				return MovieClip(displayObject);
			}
		}
		
		private function getNetStream(parameters:Object):NetStream{
			var item:LazyLoaderItem = getLazyLoaderItem(parameters);				
			if(!(item.loader is NetStream)){
				throw new Error("Resource " + item.url + " is not a NetStream.");
			}else{
				return NetStream(item.loader);
			}
		}
		
		private function getNetStreamMetadata(parameters:Object):Object{
			var uniqueId:String = getUniqueId(parameters);
			var stream:NetStream = getNetStream(uniqueId);
			if(!items[uniqueId]){
				throw new Error("Resource not loaded.");
			}else if(!(items[uniqueId].loader is NetStream)){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a NetStream.");
			}else{
				return items[uniqueId].loader.metadata;
			}
		}
		
		private function getSound(parameters:Object):Sound{
			var uniqueId:String = getUniqueId(parameters);
			if(!loaded[uniqueId]){
				throw new Error("Resource not loaded.");
			}else if(!(loaded[uniqueId].loader is Sound)){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a Sound object.");
			}else{
				return Sound(loaded[uniqueId].loader);
			}
		}
		
		private function getData(parameters:Object):String{
			var uniqueId:String = getUniqueId(parameters);
			if(!loaded[uniqueId]){
				for(var i:String in parameters) trace(i, parameters[i]);
				throw new Error("Resource not loaded.");
			}else if(!loaded[uniqueId].data){
				throw new Error("Resource " + loaded[uniqueId].url + " is not text data.");
			}else{
				return String(loaded[uniqueId].data);
			}
		}
		
		private function getXML(parameters:Object):XML{
			var uniqueId:String = getUniqueId(parameters);
			var data:String = getData(parameters);
			try{
				return new XML(data); 
			}catch(e:Error){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a valid XML.");
			}
			return new XML();
		}
		
		private function getByteArray(parameters:Object):ByteArray{
			var uniqueId:String = getUniqueId(parameters);
			var data:String = getData(uniqueId);
			try{
				var byteArray:ByteArray = new ByteArray();
				byteArray.writeUTFBytes(data);
				return byteArray;
			}catch(e:Error){
				throw new Error("Resource " + loaded[uniqueId].url + " is not a valid ByteArray.");
			}
			return new ByteArray();
		}
		
		private function get status():String{
			return _isLoading ? LazyLoaderStatus.LOADING : LazyLoaderStatus.IDLE;
		}
		
		private function getSizes():void{
			toGetSize = toBeLoaded.slice();
			for(var i:String in toGetSize){
				getSize(items[toGetSize[i]]);
			}
		}
		
		private function getSize(item:LazyLoaderItem):void{
			var sizeGetter:SizeGetter = new SizeGetter();
			sizeGetter.getSize(item);
			sizeGetter.addEventListener(Event.COMPLETE, sizeListener);
		}
		
		private function sizeListener(evt:Event):void{
			var loader:SizeGetter = evt.currentTarget as SizeGetter;
			if(loader.bytesTotal <= 0) return;
			loader.removeEventListener(Event.COMPLETE, sizeListener);
			
			items[loader.item.uniqueId].bytesTotal = loader.bytesTotal;
			toGetSize.splice(toGetSize.indexOf(loader.item.uniqueId),1);
			
			if(toGetSize.length==0) dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.COMPLETED_GETTING_SIZE));
		}
		
		private function loadNext():void{
			if(toBeLoaded.length>0){
				while(connections.length < Math.min(_maxConnections, toBeLoaded.length)) load(toBeLoaded.shift());
			}
			if(toBeLoaded.length <= 0 && connections.length <= 0){
				completed();
			}
		}
		
		private function load(uniqueId:String):void{
			var connection:Connection = new Connection(items[uniqueId]);
			connections.push(connection);
			connection.addEventListener(Event.COMPLETE, completeListener);
			connection.addEventListener(Event.CLOSE, completeListener);
			connection.addEventListener(IOErrorEvent.IO_ERROR, errorListener);
			connection.addEventListener(ProgressEvent.PROGRESS, progressListener);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorListener);
			connection.load();
		}
		
		private function completeListener(event:Event):void{
			var uniqueId:String = Connection(event.currentTarget).uniqueId;
			loaded[uniqueId] = items[uniqueId];
			
			connections.splice(connections.indexOf(Connection(event.currentTarget)),1);
			
			event.currentTarget.removeEventListener(ProgressEvent.PROGRESS, progressListener);
			event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, errorListener);
			event.currentTarget.removeEventListener(Event.COMPLETE, completeListener);
			event.currentTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorListener);
			event.currentTarget.removeEventListener(Event.CLOSE, completeListener);
			
			loadNext();
		}
		
		private function progressListener(event:ProgressEvent):void{
			var bytesTotal:int = 0;
			var positiveBytesTotalCount:int = 0;
			var averageBytesTotal:int = 0;
			var bytesLoaded:int = 0;
			var filesTotal:int = 0;
			var filesLoaded:int = 0;
			var currentObject:LazyLoaderItem = Connection(event.currentTarget).item;
			currentObject.bytesTotal = Math.max(event.bytesTotal, currentObject.bytesTotal);
			currentObject.bytesLoaded = event.bytesLoaded;
			
			for(var i:String in loading){
				filesTotal++;
				if(loaded[i]) filesLoaded++;
				bytesLoaded += loading[i].bytesLoaded;
				if(loading[i].bytesTotal>0) positiveBytesTotalCount++;
				bytesTotal+= loading[i].bytesTotal;
			}
			
			if(positiveBytesTotalCount < filesTotal){
				averageBytesTotal = bytesTotal/positiveBytesTotalCount;
				bytesTotal = 0;
				for(i in loading) bytesTotal += items[i].bytesTotal>0 ? items[i].bytesTotal : averageBytesTotal;
			}
		
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.PROGRESS, bytesLoaded, bytesTotal, filesLoaded, filesTotal, event.bytesLoaded, event.bytesTotal));
		}
		
		private function errorListener(event:ErrorEvent):void{
			var loader:Object = Connection(event.currentTarget).item.internalLoader;
			
			trace("Error loading " + loader.relativeURL + ". Skipping.");
			
			event.currentTarget.removeEventListener(ProgressEvent.PROGRESS, progressListener);
			event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, errorListener);
			event.currentTarget.removeEventListener(Event.COMPLETE, completeListener);
			event.currentTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorListener);
			
			connections.splice(connections.indexOf(Connection(event.currentTarget)),1);
			
			items[loader.uniqueId].isLoading = false;
			
			loadNext();
		}
		
		private function completed():void{
			_isLoading=false;
			loading = new Dictionary();
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.COMPLETE));
		}
		
		private function addNode(uniqueId:String, url:String, attributes:Object):void{
			var node:String = "<file url='" + url + "' lazy_loader_unique_id='" + uniqueId + "'";
			
			if(attributes) delete attributes.context;
			
			if(attributes) for(var i:String in attributes){
				node += " " + i + "='" + attributes[i]+"'";
			}
			node+=" />";
			
			data.appendChild(new XML(node));
		}
		
		private function getUniqueId(parameters:Object):String{
			var list:XMLList;
			if(parameters is XMLList) parameters = String(parameters);
			if(parameters is String){
				
				if(String(data..file.(attribute("lazy_loader_unique_id") == parameters).@lazy_loader_unique_id).length>0){
					return String(data..file.(@lazy_loader_unique_id==parameters).@lazy_loader_unique_id);
				}
				
				if(String(data..file.(attribute("url") == parameters).@lazy_loader_unique_id).length>0){
					list = data..file.(attribute("url") == parameters);
					return String(list[list.length() - 1].@lazy_loader_unique_id);
				}
				
				if(String(data..file.(attribute("id") == parameters).@lazy_loader_unique_id).length>0){
					list = data..file.(attribute("id") == parameters);
					return String(list[list.length() - 1].@lazy_loader_unique_id);
				}
				
				throw new Error("Can't find resource with id/url: " + parameters);
				
			}else{
				list = new XMLList(data..file);
				for(var i:String in parameters){
					if(String(list.attribute(i)).length <= 0) throw new Error("Can't find resource with parameters: " + parameters);
					list = new XMLList(list.(attribute(i) == parameters[i]));
				}
				return list[list.length()-1].@lazy_loader_unique_id;
			}
		}
		
		private function createUniqueId():String{
			var uniqueId:String = "";
			var pattern:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*";
			while(uniqueId.length<15) uniqueId+= pattern.charAt(Math.floor(Math.random()*pattern.length)); 
			if(items[uniqueId]) uniqueId = createUniqueId();
			return uniqueId;
		}

	}
}

internal class Singleton{
	public function Singleton(){}
}