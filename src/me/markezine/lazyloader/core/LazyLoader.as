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
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.net.NetStream;
	import flash.system.ApplicationDomain;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	
	/**
	 * The <code>LazyLoader</code> class is a loading queue that manages loading multiple files. 
	 * It also stores content to be used later in a easier way.
	 * @param id The id of the current <code>LazyLoader</code>. You can retrieve this instance by 
	 * calling <code>LazyLoader.getInstance()</code>
	 * @see LazyLoader.getInstance 
	 */
	[Event(name="open", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="size_complete", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="complete", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="progress", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="canceled", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	
	public class LazyLoader extends EventDispatcher
	{
		public static var defaultApplicationDomain:ApplicationDomain = null;
		public static var defaultSecurityDomain:SecurityDomain = null;
		public static var debugMode:String = LazyLoaderDebugModes.ERRORS;
		public static var debugOnJavascriptConsole:Boolean = false;
		
		private static var instances:Dictionary = new Dictionary();
		private static var items:ItemList = new ItemList();
		
		internal var added:Vector.<String>;
		internal var waiting:Vector.<String>;
		internal var loading:Vector.<String>;
		
		internal var queue:Vector.<String>;
		
		private var _id:String;
		private var _status:String;
		private var _started:Boolean = false;
		private var _maxConnections:Number = 4;
		private var _destroyed:Boolean = false;
		private var _prevBytesLoaded:uint = 0;
		public var debugMode:String = "";
		
		/**
		 * The <code>LazyLoader</code> class is a loading queue that manages loading multiple 
		 * files. It also stores content to be used later in a easier way.
		 * @param id The id of the current <code>LazyLoader</code>. You can retrieve this instance 
		 * by calling <code>LazyLoader.getInstance("id")</code> 
		 */
		public function LazyLoader(id:String = "default"):void{
			super();
			if(instances[id]) LazyLoader(instances[id]).destroy();
			instances[id] = this;
			_id = id;
			_status = LazyLoaderStatus.WAITING;
			this.debugMode = LazyLoader.debugMode;
			
			added = new Vector.<String>();
			waiting = new Vector.<String>();
			loading = new Vector.<String>();
			queue = new Vector.<String>();
		}
		
		/**
		 * Returns the <code>LazyLoader</code> instance for the given id.
		 * @param id The id of the instance.
		 * @param autoCreate If set to <code>true</code> and there's no instance associated with the 
		 *  id, creates a new one.
		 * @return The <code>LazyLoader</code> associated with the given id. 
		 */		
		static public function getInstance(id:String = "default", autoCreate:Boolean = true):LazyLoader{
			if(!instances[id] && autoCreate) new LazyLoader(id);
			return LazyLoader(instances[id]);
		}
		
		
		/**
		 * Returns if a instance with a given id already exists or not.  
		 * @param id The id of the instance.
		 * @return <code>true</code> if the instance already exists. 
		 */		
		static public function hasInstance(id:String):Boolean{
			return Boolean(instances[id]);
		}
		
		
		/**
		 * @inheritDoc 
		 * 
		 */
		static public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:uint = 0, useWeakReference:Boolean = true):void{
			getInstance().addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */
		static public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			getInstance().removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Adds a item to the loading queue. If called on the class adds to the default instance.
		 * @param request The request to be loaded. It can be either a <code>URLRequest</code> or a
		 * string containing the url of the file to be loaded.
		 * @param attributes Attributes that can be specified either to be searched later or adding 
		 * special parameters to the loading process. You can use a <code>String</code> instead of 
		 * a object containing parameters, and the LazyLoader will use it as the item id. There is 
		 * a <code>LazyLoaderVariables</code> class with the default parameters that you can use 
		 * to add items as well.
		 * @return A <code>LazyLoaderItem</code> with the current request and parameters.  
		 * @see LazyLoaderItem
		 * @see LazyLoaderVariables
		 */
		public function add(request:Object, attributes:Object = null):LazyLoaderItem{
			var item:LazyLoaderItem;
			if(request is LazyLoaderGroup){
				for each(var groupItem:LazyLoaderItem in LazyLoaderGroup(request).items){
					add(groupItem);
				}
				return null;
			}else if(request is LazyLoaderItem){
				item = LazyLoaderItem(request);
			}else{
				if(attributes is LazyLoaderVariables) LazyLoaderVariables(attributes).toObject(); 
				item = new LazyLoaderItem(request, attributes);
			}
			
			item.instance = id;
			item.uniqueId = items.addItem(item);
			item.addEventListener(Event.OPEN, itemListener);
			item.addEventListener(LazyLoaderErrorEvent.LAZYLOADER_ERROR, itemListener, false, int.MAX_VALUE - 1);
			
			if(_started) {
				waiting.push(item.uniqueId);
				item.getSize();
			} else {
				_status = LazyLoaderStatus.WAITING;
				added.push(item.uniqueId);
			}
			
			queue.push(item.uniqueId);
			
			LazyLoaderDebugger.debug(this, LazyLoaderDebugModes.ADD, item);
			
			return item;
		}
		
		/**
		 * @private
		 */
		static public function add(request:Object, attributes:Object = null):LazyLoaderItem{
			return getInstance().add(request, attributes);
		}
		
		/**
		 * Start the loading process. If called on the class starts on the default instance.
		 * @param getSizeFirst defines if the LazyLoader must check what are the size of the files 
		 * before loading them. It's recommended to stay as <code>true</code> 
		 * if you are loading more files than you maxConnections value.
		 * @see maxConnections
		 */		
		public function start(getSizeFirst:Boolean = true):void{
			if(_started) return;
			_started = true;
			
			if(getSizeFirst) getSizes();
			
			fillConnections();
		}
		
		/**
		 * @private
		 */
		static public function start(getSizeFirst:Boolean = true):void{
			getInstance().start(getSizeFirst);
		}
		
		/**
		 * Stops the loading process and destroys every item that haven't been completed yet. Also 
		 * cleans the current queue. If called on the class, stops the default instance.
		 */		
		public function stop():void{
			while(queue.length > 0){
				var uniqueid:String = queue[0];
				var item:LazyLoaderItem = items.getItem(uniqueid);
				item.removeEventListener(Event.OPEN, itemListener);
				item.removeEventListener(LazyLoaderEvent.PROGRESS, itemListener);
				item.removeEventListener(LazyLoaderEvent.COMPLETE, itemListener);
				item.removeEventListener(LazyLoaderEvent.CANCELED, itemListener);
				item.close();
				
				if(loading.indexOf(uniqueid) > -1 || added.indexOf(uniqueid) > -1 ||
					waiting.indexOf(uniqueid) > -1) items.destroyItem(uniqueid);
				
				LazyLoaderUtils.removeFromVector(loading, uniqueid);
				LazyLoaderUtils.removeFromVector(added, uniqueid);
				LazyLoaderUtils.removeFromVector(waiting, uniqueid);
				LazyLoaderUtils.removeFromVector(queue, uniqueid);
			}
			
			_started = false;
			_status = LazyLoaderStatus.CANCELED;
		}
		
		/** 
		 * @private
		 */
		static public function stop():void{
			getInstance().stop();
		}
		
		/**
		 * Prioritize all the items that matches the current parameters. If the parameters have no match
		 * or the matches have already been loaded, it does nothing. 
		 * @param parameters The parameters that needs to match to prioritize a file.
		 */
		public function prioritize(parameters:Object):void{
			var list:Vector.<LazyLoaderItem>;
			
			if(parameters is LazyLoaderGroup){
				list = new Vector.<LazyLoaderItem>();
				for each(var groupItem:LazyLoaderItem in LazyLoaderGroup(parameters)){
					list.push(groupItem);
				}
			}else{
				list = items.getItemList(parameters, id);
			}
			
			var toBePrioritezed:Vector.<String> = new Vector.<String>();
			for each(var item:LazyLoaderItem in list){
				var itemIndex:Number = added.indexOf(item.uniqueId);
				if(itemIndex > -1){
					added.splice(itemIndex, 1);
					toBePrioritezed.push(item.uniqueId);
				}
				
				itemIndex = loading.indexOf(item.uniqueId);
				if(itemIndex < -1){
					loading.splice(itemIndex, 1);
					toBePrioritezed.push(item.uniqueId);
				}
			}
			
			if(toBePrioritezed.length>0){
				pause();
				for each(var itemId:String in toBePrioritezed){
					added.unshift(itemId);
				}
				start();
			}
		}
		
		/**
		 * @private
		 **/
		public static function prioritize(parameters:Object):void{
			getInstance().prioritize(parameters);
		}
		
		/**
		 * Pauses the loading process. The files that have been added but not loaded yet will be 
		 * loaded in the next <code>start</code> call. If called on the class, pauses the default
		 * instance.
		 * @see start
		 */
		public function pause():void{
			while(loading.length > 0){
				var uniqueid:String = loading[0];
				var item:LazyLoaderItem = items.getItem(uniqueid);
				item.removeEventListener(LazyLoaderEvent.PROGRESS, itemListener);
				item.removeEventListener(LazyLoaderEvent.COMPLETE, itemListener);
				item.removeEventListener(LazyLoaderEvent.CANCELED, itemListener);
				item.close();
				LazyLoaderUtils.removeFromVector(loading, uniqueid);
				LazyLoaderUtils.addToVector(added, uniqueid);
			}
			
			_started = false;
			_status = LazyLoaderStatus.PAUSED;
		}
		
		/** 
		 * @private
		 */
		static public function pause():void{
			getInstance().pause();
		}
		
		/**
		 * Destroys the LazyLoader instance and all the items associated to it. Please be aware 
		 * that when you destroy an instance, all it's items become inacessible. 
		 * 
		 */
		public function destroy():void{
			stop();
			items.destroyInstance(_id);
			_destroyed = true;
			
			added = null;
			waiting = null;
			loading = null;
			queue = null;
			instances[_id] = null;
		}
		
		private function getSizes():void{
			for(var i:String in queue){
				items.getItem(queue[i]).getSize();
			}
		}
		
		private function fillConnections():void{
			while(added.length>0) waiting.push(added.shift());
			while(loading.length < maxConnections && waiting.length > 0){
				var uniqueid:String = waiting[0];
				items.getItem(uniqueid).load();
				LazyLoaderUtils.addToVector(loading, uniqueid);
				LazyLoaderUtils.removeFromVector(added, uniqueid);
				LazyLoaderUtils.removeFromVector(waiting, uniqueid);
			}
		}
		
		private function itemListener(event:Event):void{
			var item:LazyLoaderItem = LazyLoaderItem(event.currentTarget);
			switch(event.type){
				case Event.OPEN:
					_status = LazyLoaderStatus.LOADING;
					if(hasEventListener(LazyLoaderEvent.PROGRESS)) item.addEventListener(LazyLoaderEvent.PROGRESS, itemListener, false, int.MAX_VALUE - 1);
					item.addEventListener(LazyLoaderEvent.COMPLETE, itemListener, false, int.MAX_VALUE - 1);
					item.addEventListener(LazyLoaderEvent.CANCELED, itemListener, false, int.MAX_VALUE - 1);
					
					LazyLoaderUtils.removeFromVector(added, item.uniqueId);
					LazyLoaderUtils.removeFromVector(waiting, item.uniqueId);
					LazyLoaderUtils.addToVector(loading, item.uniqueId);
					break;
				
				case LazyLoaderEvent.PROGRESS:
					if(bytesLoaded != _prevBytesLoaded){
						_prevBytesLoaded = bytesLoaded;
						dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.PROGRESS, bytesLoaded, bytesTotal));
					}
					break;
				
				case LazyLoaderErrorEvent.LAZYLOADER_ERROR:
					LazyLoaderDebugger.debug(this, LazyLoaderDebugModes.ERRORS, item, LazyLoaderErrorEvent(event).originalEvent.type);
				case LazyLoaderEvent.COMPLETE:
					item.removeEventListener(Event.OPEN, itemListener);
					item.removeEventListener(LazyLoaderEvent.PROGRESS, itemListener);
					item.removeEventListener(LazyLoaderEvent.CANCELED, itemListener);
					item.removeEventListener(LazyLoaderEvent.COMPLETE, itemListener);
					LazyLoaderUtils.removeFromVector(loading, item.uniqueId);
					
					if(waiting.length == 0 && loading.length == 0 && _started){
						_started = false;
						_status = LazyLoaderStatus.COMPLETE;
						dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.COMPLETE, bytesLoaded, bytesTotal));
					}else if(waiting.length == 0 && loading.length == 0 && added.length == 0  && !_started){
						_status = LazyLoaderStatus.COMPLETE;
					}else if (waiting.length > 0 && _started){
						fillConnections();
					}else if (loading.length == 0 && added.length > 0 && !_started){
						_status = LazyLoaderStatus.WAITING;
					}
					
					break;
				
				case LazyLoaderEvent.CANCELED:
					LazyLoaderUtils.removeFromVector(loading, item.uniqueId);
					LazyLoaderUtils.addToVector(waiting, item.uniqueId);
					if(_started) fillConnections();
					break;
			}
		}
		
		/**
		 * You can use this method to check if a item with the current parameters has been added.
		 * You can also use a string to match the item id or url. If called on the class, searches 
		 * the parameter in all instances.
		 * @param parameters The search parameters to get the item.
		 * @return the <code>Boolean</code> if the item has been added or not. 
		 */
		public function hasItem(parameters:Object):Boolean{
			return Boolean(items.getItem(parameters, id));
		}
		
		static public function hasItem(parameters:Object):Boolean{
			return Boolean(items.getItem(parameters));
		}
		
		/**
		 * You can use this method to check if a item with the current parameters has been already 
		 * loaded. You can also use a string to match the item id or url. If called on the class, 
		 * searches the parameter in all instances. 
		 * @param parameters The search parameters to get the item.
		 * @return the <code>Boolean</code> if the item has been loaded or not. 
		 */
		public function isLoaded(parameters:Object):Boolean{
			var item:LazyLoaderItem = items.getItem(parameters, id); 
			return item && item.status == LazyLoaderStatus.COMPLETE;
		}
		
		static public function isLoaded(parameters:Object):Boolean{
			var item:LazyLoaderItem = items.getItem(parameters);
			return item && item.status == LazyLoaderStatus.COMPLETE;
		}
		
		/**
		 * You can use this method to retrieve a <code>LazyLoaderItem</code> that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item. If called on the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>LazyLoaderItem</code> matching the current parameters. 
		 * @see LazyLoaderItem
		 */
		public function getItem(parameters:Object):LazyLoaderItem{
			var item:LazyLoaderItem = items.getItem(parameters, id);
			if(!item) LazyLoaderDebugger.debug(this, LazyLoaderDebugModes.ERRORS, item, 
				"no matching item" + (parameters is String ? parameters : parameters.id || parameters.url)); 
			return item;
		}
		
		/**
		 * @private
		 */
		static public function getItem(parameters:Object):LazyLoaderItem{
			var item:LazyLoaderItem = items.getItem(parameters);
			if(!item) LazyLoaderDebugger.debug(LazyLoader.getInstance(), LazyLoaderDebugModes.ERRORS, item, 
				"no matching item" + (parameters is String ? parameters : parameters.id || parameters.url)); 
			return item;
		}
		
		/**
		 * You can use this method to retrieve a <code>LazyLoaderGroup</code> that matches the 
		 * properties of the parameters object. You can also use a string to match the items id or 
		 * url. If called on the class, searches the parameter in default instance.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>LazyLoaderGroup</code> matching the current parameters. 
		 * @see LazyLoaderGroup
		 */
		public function getGroup(parameters:Object):LazyLoaderGroup{
			var group:LazyLoaderGroup = new LazyLoaderGroup(this);
			var list:Vector.<LazyLoaderItem> = items.getItemList(parameters, id);
			for each(var item:LazyLoaderItem in list){
				group.addItem(item);
			}
			return group;
		}
		
		/**
		 * @private
		 */
		static public function getGroup(parameters:Object):LazyLoaderGroup{
			return getInstance().getGroup(parameters);
		}
		
		/**
		 * You can use this method to retrieve a <code>ByteArray</code> data that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item.
		 * If the item is not binary, it will return <code>null</code>.
		 * If called on the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>ByteArray</code> matching the current parameters. 
		 * 
		 */
		public function getByteArray(parameters:Object):ByteArray{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.data is ByteArray) return ByteArray(item.data);
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getByteArray(parameters:Object):ByteArray{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.data is ByteArray) return ByteArray(item.data);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>String</code> data that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item.
		 * If the item is not text, it will return <code>null</code>.
		 * If called on the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>String</code> matching the current parameters. 
		 * 
		 */
		public function getData(parameters:Object):String{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item.data is String) return String(item.data);
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getData(parameters:Object):String{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item.data is String) return String(item.data);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>XML</code> data that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item. If called on the class, searches the parameter in all 
		 * instances.
		 * If the item is not XML data, it will return <code>null</code>.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>XML</code> matching the current parameters. 
		 * 
		 */
		public function getXML(parameters:Object):XML{
			var item:LazyLoaderItem = this.getItem(parameters);
			try{
				return new XML(item.data);
			}catch(e:Error){}
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getXML(parameters:Object):XML{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			try{
				return new XML(item.data);
			}catch(e:Error){}
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>NetStream</code> object that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item. If called on the class, searches the parameter in all 
		 * instances.
		 * If the item is not a <code>NetStream</code> object, it will return <code>null</code>.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>NetStream</code> matching the current parameters. 
		 * 
		 */
		public function getNetStream(parameters:Object):NetStream{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is NetStream) return NetStream(item.content);
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getNetStream(parameters:Object):NetStream{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is NetStream) return NetStream(item.content);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>Sound</code> object that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item. If called on the class, searches the parameter in all 
		 * instances.
		 * If the item is not a <code>Sound</code> object, it will return <code>null</code>.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>Sound</code> matching the current parameters. 
		 * 
		 */
		public function getSound(parameters:Object):Sound{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is Sound) return Sound(item.content);
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getSound(parameters:Object):Sound{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is Sound) return Sound(item.content);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>NetStream</code> or <code>Sound</code>
		 * metadata that match the properties of the parameters object. You can also use a string 
		 * to match the item id or url. Please note that if there are more than one item with the 
		 * same parameters, it will return the last added item. 
		 * If the item is not a <code>Sound</code> or <code>Netstream</code> object, it will 
		 * return <code>null</code>. If called on the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>Sound</code> matching the current parameters. 
		 * 
		 */
		public function getMetadata(parameters:Object):Object{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is Sound) return Sound(item.content).id3;
			if(item && item.content is CustomNetStream) return CustomNetStream(item.content).metadata;
			return null;
		}
		
		
		/**
		 * @private
		 */
		static public function getMetadata(parameters:Object):Object{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is Sound) return Sound(item.content).id3;
			if(item && item.content is CustomNetStream) return CustomNetStream(item.content).metadata;
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>Sprite</code> that matches the properties 
		 * of the parameters object. You can also use a string to match the item id or url.
		 * Please note that if there are more than one item with the same parameters, it will
		 * return the last added item.
		 * If the item is not a <code>Sprite</code>, it will return <code>null</code>.
		 * If called on the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>Sprite</code> matching the current parameters. 
		 * 
		 */
		public function getSprite(parameters:Object):Sprite{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is Sprite) return Sprite(item.content);
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getSprite(parameters:Object):Sprite{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is Sprite) return Sprite(item.content);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>MovieClip</code> that matches the properties 
		 * of the parameters object. You can also use a string to match the item id or url.
		 * Please note that if there are more than one item with the same parameters, it will
		 * return the last added item.
		 * If the item is not a <code>MovieClip</code>, it will return <code>null</code>. If called 
		 * on the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>MovieClip</code> matching the current parameters. 
		 * 
		 */
		public function getMovieClip(parameters:Object):MovieClip{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is MovieClip) return MovieClip(item.content);
			return null;
		}
		
		static public function getMovieClip(parameters:Object):MovieClip{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is MovieClip) return MovieClip(item.content);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>Bitmap</code> that matches the properties 
		 * of the parameters object. You can also use a string to match the item id or url.
		 * Please note that if there are more than one item with the same parameters, it will
		 * return the last added item.
		 * If the item is not a <code>Bitmap</code>, it will return <code>null</code>. If called on 
		 * the class, searches the parameter in all 
		 * instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>Bitmap</code> matching the current parameters. 
		 * 
		 */
		public function getBitmap(parameters:Object):Bitmap{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is Bitmap) return Bitmap(item.content);
			return null;
		}
		
		/**
		 * @private
		 */
		static public function getBitmap(parameters:Object):Bitmap{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is Bitmap) return Bitmap(item.content);
			return null;
		}
		
		/**
		 * You can use this method to retrieve a <code>BitmapData</code> that matches the 
		 * properties of the parameters object. You can also use a string to match the item id or 
		 * url. Please note that if there are more than one item with the same parameters, it will
		 * return the last added item.
		 * If the item is not a <code>Bitmap</code>, it will return <code>null</code>. If called on
		 * the class, searches the parameter in all instances.
		 * @param parameters The search parameters to get the item.
		 * @return The <code>BitmapData</code> matching the current parameters. 
		 * 
		 */
		public function getBitmapData(parameters:Object):BitmapData{
			var item:LazyLoaderItem = this.getItem(parameters);
			if(item && item.content is Bitmap) return Bitmap(item.content).bitmapData.clone();
			return null;
		}
		
		
		/**
		 * @private
		 */
		static public function getBitmapData(parameters:Object):BitmapData{
			var item:LazyLoaderItem = LazyLoader.getItem(parameters);
			if(item && item.content is Bitmap) return Bitmap(item.content).bitmapData.clone();
			return null;
		}
		
		/** 
		 * The sum of the bytes loaded by the current queue. If called on the class, returns the 
		 * value for the default instance.
		 */
		public function get bytesLoaded():uint{
			var _loaded:uint = 0;
			for(var i:String in queue) _loaded += items.getItem(queue[i]).bytesLoaded;
			return _loaded;
		}
		
		/**
		 * @private
		 */
		static public function get bytesLoaded():uint{
			return getInstance().bytesLoaded;
		}
		
		/** 
		 * The sum of the total bytes of the current queue. If called on the class, returns the 
		 * value for the default instance.
		 */		
		public function get bytesTotal():uint{
			var _total:uint = 0;
			for(var i:String in queue) _total += items.getItem(queue[i]).bytesTotal;
			return _total;
		}
		static public function get bytesTotal():uint{
			return getInstance().bytesTotal;
		}
		
		/** 
		 * The status of the <code>LazyLoader</code>. If called on the class, returns the 
		 * value for the default instance.
		 * @see LazyLoaderStatus
		 */		
		public function get status():String { return _status; }
		static public function get status():String { return getInstance()._status; }
		
		/**
		 * The id of the LazyLoader instance.
		 * @see LazyLoader.getInstance
		 */		
		public function get id():String { return _id; }

		/**
		 * The maximum number of simultaneous connections the instance should handle.
		 * @default 4
		 */		
		public function get maxConnections():Number{return _maxConnections;}
		static public function get maxConnections():Number{return getInstance().maxConnections;}
		
		/**
		 * @private
		 */		
		public function set maxConnections(value:Number):void{
			_maxConnections = value;
			if(_started) fillConnections();
		}
		static public function set maxConnections(value:Number):void{
			getInstance().maxConnections = value;
		}
	}
}