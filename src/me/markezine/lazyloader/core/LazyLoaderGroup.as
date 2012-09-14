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
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	
	[Event(name="complete", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="progress", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	
	/**
	 * The LazyLoaderGroup class is a class used to listen to events of a group of 
	 * <code>LazyLoaderItem</code>. The recommended method to create a LazyLoaderGroup is to call
	 * LazyLoader.getGroup from a LazyLoader instance.
	 */
	public class LazyLoaderGroup extends EventDispatcher
	{
		internal var items:Dictionary;
		private var loader:LazyLoader;
		
		private var _bytesLoaded:uint = 0;
		private var _bytesTotal:uint = 0;
		
		/**
		 * The LazyLoaderGroup class is a class used to listen to events of a group of 
		 * <code>LazyLoaderItem</code>. The recommended method to create a LazyLoaderGroup is to call
		 * LazyLoader.getGroup from a LazyLoader instance.
		 * 
		 */
		public function LazyLoaderGroup(loader:LazyLoader)
		{
			super();
			this.loader = loader;
			items = new Dictionary();
		}
		
		/**
		 * This method can be used to add a item to the group after it is created.
		 */
		public function addItem(item:LazyLoaderItem):void{
			if(item.status == LazyLoaderStatus.COMPLETE) return;
			if(loader && !loader.hasItem(item.uniqueId)){
				loader.add(item);
			}
			items[item.uniqueId] = item;
			item.addEventListener(LazyLoaderEvent.PROGRESS, progressListener);
			item.addEventListener(LazyLoaderEvent.COMPLETE, progressListener);
		}
		
		/**
		 * This method can be used to prioritize all the items in the current group.
		 */
		public function prioritize():void{
			if(loader) loader.prioritize(this);
		}
		
		private function progressListener(event:LazyLoaderEvent):void{
			var loaded:uint = 0;
			var total:uint = 0;
			var complete:Boolean = true;
			for each(var item:LazyLoaderItem in items){
				if(loader.queue.indexOf(item.uniqueId) > -1){
					if(item.status != LazyLoaderStatus.COMPLETE) complete = false;
					loaded += item.bytesLoaded;
					total += item.bytesTotal;
				}
			}
			
			if(event.type == LazyLoaderEvent.COMPLETE){
				event.currentTarget.removeEventListener(LazyLoaderEvent.PROGRESS, progressListener);
				event.currentTarget.removeEventListener(LazyLoaderEvent.COMPLETE, progressListener);
			}
			
			_bytesLoaded = loaded;
			_bytesTotal = total;
			
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.PROGRESS, bytesLoaded, bytesTotal));	
			if(complete) dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.COMPLETE, bytesLoaded, bytesTotal));
		}
		
		/**
		 *  The sum of the total bytes of the items. 
		 */
		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
		/**
		 *  The sum of the loaded bytes of the items. 
		 */
		public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}
		
		/**
		 *  The status of the items being loaded. 
		 */
		public function get status():String{
			for each(var item:LazyLoaderItem in items){
				if(item.status == LazyLoaderStatus.LOADING ||
				item.status == LazyLoaderStatus.WAITING) return item.status;
			}
			return LazyLoaderStatus.COMPLETE;
		}
	}
}