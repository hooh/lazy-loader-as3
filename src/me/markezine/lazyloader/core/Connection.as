package me.markezine.lazyloader.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	
	internal class Connection extends EventDispatcher
	{
		private var _item:LazyLoaderItem;
		
		public function Connection(item:LazyLoaderItem)
		{
			super();
			_item = item;
			
		}
		
		internal function load():void{
			switch(_item.type){
				case ItemType.BITMAP:
				case ItemType.FLASH:
					loadDisplayObject();
					break;
				
				case ItemType.VIDEO:
					loadVideo();
					break;
				
				case ItemType.AUDIO:
					loadAudio();
					break;
				
				case ItemType.BINARY:
					loadText(true);
					
				default:
					loadText(false);
					break;
			}
		}
		
		private function loadAudio():void{
			_item.internalLoader = _item.internalLoader || new CustomSound();
			loadGeneral(_item.internalLoader, _item.internalLoader);
		}
		
		private function loadVideo():void{
			_item.internalLoader = _item.internalLoader || new CustomNetStream();
			loadGeneral(_item.internalLoader, _item.internalLoader);
		}
		
		private function loadDisplayObject():void{
			_item.internalLoader = _item.internalLoader || new CustomLoader();
			loadGeneral(_item.internalLoader, _item.internalLoader.contentLoaderInfo);
		}
		
		private function loadText(binary:Boolean):void{
			_item.internalLoader = _item.internalLoader || new CustomURLLoader();
			_item.internalLoader.dataFormat = binary ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
			loadGeneral(_item.internalLoader, _item.internalLoader);
		} 
		
		private function loadGeneral(loader:Object, listener:Object):void{
			loader.uniqueId = _item.uniqueId;
			listener.addEventListener(Event.OPEN, loaderListener);
			listener.addEventListener(Event.COMPLETE, loaderListener);
			
			listener.addEventListener(IOErrorEvent.IO_ERROR, loaderListener);
			listener.addEventListener(ProgressEvent.PROGRESS, loaderListener);
			listener.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderListener);
			
			listener.addEventListener(NetStatusEvent.NET_STATUS, loaderListener);
			listener.addEventListener(LazyLoaderEvent.METADATA_RECEIVED, loaderListener);
			if(!_item.isLoading) {
				if(loader is CustomLoader || loader is CustomSound){
					loader.load(_item.request, _item.context || LazyLoader.defaultContext);
				}else{
					loader.load(_item.request);
				}
			}
		}
		
		private function loaderListener(event:Event):void{
			switch(event.type){
				case Event.OPEN:
					_item.dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.OPEN));
					_item.isLoading = true;
					break;
				
				case Event.COMPLETE:
					event.currentTarget.removeEventListener(Event.OPEN, loaderListener);
					event.currentTarget.removeEventListener(Event.COMPLETE, loaderListener);
					
					event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, loaderListener);
					event.currentTarget.removeEventListener(ProgressEvent.PROGRESS, loaderListener);
					event.currentTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderListener);
					
					dispatchEvent(new Event(Event.COMPLETE));
					_item.dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.COMPLETE));
					_item.isLoading = false;
					break;
				
				case NetStatusEvent.NET_STATUS:
					if(NetStatusEvent(event).info.code == "NetStream.Buffer.Full"){
						event.currentTarget.removeEventListener(NetStatusEvent.NET_STATUS, loaderListener);
						_item.dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.BUFFER_FULL));
						_item.loader.dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.BUFFER_FULL));
					}
					break;
				
				case LazyLoaderEvent.METADATA_RECEIVED:
					event.currentTarget.removeEventListener(LazyLoaderEvent.METADATA_RECEIVED, loaderListener);
					_item.dispatchEvent(event);
					break;
				
				default:
					dispatchEvent(event);
					_item.dispatchEvent(event);
					break;
			}
		}
		
		public function pause():void{
			try{_item.internalLoader.close();}catch(e:Error){};
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function stop():void{
			try{_item.internalLoader.close();}catch(e:Error){};
			dispatchEvent(new Event(Event.CLOSE));
		}

		internal function get item():LazyLoaderItem{
			return _item;
		}
		
		internal function get uniqueId():String{
			return item.uniqueId;
		}
	}
}



