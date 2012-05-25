package me.markezine.lazyloader.core
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	
	
	internal class CustomURLLoader extends URLLoader implements ICustomLoader{
		
		private var request:URLRequest;
		private var _status:String = LazyLoaderStatus.WAITING;
		
		public function CustomURLLoader(){
			super(null);
		}
		
		public function lazyLoad(request:URLRequest, context:Object = null):void{
			if(_status!=LazyLoaderStatus.WAITING && status != LazyLoaderStatus.CANCELED && status!=LazyLoaderStatus.ERROR) return;
			_status = LazyLoaderStatus.LOADING;
			this.request = request;
			super.load(request);
			addInternalHandlers();
		}
		
		override public function load(request:URLRequest):void{
			lazyLoad(request);
		}
		
		override public function close():void{
			if(_status!= LazyLoaderStatus.LOADING) return;
			_status = LazyLoaderStatus.CANCELED;
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.CANCELED, loaded, total));
			removeInternalHandlers();
			super.close();
		}
		
		public function destroy():void{
			close();
			removeInternalHandlers();
		}
		
		private function addInternalHandlers():void{
			super.addEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			super.addEventListener(HTTPStatusEvent.HTTP_STATUS, internalHandler);
			super.addEventListener(Event.COMPLETE, internalHandler);
			super.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalHandler);
		}
		
		private function internalHandler(event:Event):void{
			switch(event.type){
				case IOErrorEvent.IO_ERROR:
					_status = LazyLoaderStatus.ERROR;
					dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
					removeInternalHandlers();
					break;
				
				case HTTPStatusEvent.HTTP_STATUS:
					if(HTTPStatusEvent(event).status < 200 || HTTPStatusEvent(event).status > 399){  
						dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
					}
					break;
				
				case SecurityErrorEvent.SECURITY_ERROR:
						_status = LazyLoaderStatus.ERROR;
						dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
						removeInternalHandlers();
					break;
				
				case Event.COMPLETE:
					_status = LazyLoaderStatus.COMPLETE;
					removeInternalHandlers();
					break;
			}
		}
		
		private function removeInternalHandlers():void{
			super.removeEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			super.removeEventListener(HTTPStatusEvent.HTTP_STATUS, internalHandler);
			super.removeEventListener(Event.COMPLETE, internalHandler);
			super.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, internalHandler);
		}
		
		public function get bytes():ByteArray {
			var bytesData:ByteArray = new ByteArray();
			bytesData.writeUTFBytes(data);
			return bytesData;
		}
		
		public function get loaded():uint{ return bytesLoaded; }
		public function get total():uint{ return bytesTotal; }
		public function get status():String{ return _status; }
		public function get metadata():Object{ return null };

	}
}