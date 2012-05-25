package me.markezine.lazyloader.core
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	
	public class CustomLoader extends Loader implements ICustomLoader{
		private var request:URLRequest;
		private var _status:String = LazyLoaderStatus.WAITING;
		
		public function CustomLoader(){
			super();
		}
		
		public function lazyLoad(request:URLRequest, context:Object=null):void{
			if(_status!=LazyLoaderStatus.WAITING && status != LazyLoaderStatus.CANCELED && status!=LazyLoaderStatus.ERROR) return;
			_status = LazyLoaderStatus.LOADING;
			this.request = request;
			if(!context) context = new LoaderContext(true);
			super.load(request, LoaderContext(context));
			addInternalHandlers();
		}
		
		override public function load(request:URLRequest, context:LoaderContext=null):void{
			lazyLoad(request, context);
		}
		
		override public function close():void{
			if(_status != LazyLoaderStatus.LOADING && _status != LazyLoaderStatus.WAITING) return;
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
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, internalHandler);
			contentLoaderInfo.addEventListener(Event.COMPLETE, internalHandler);
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
				
				case Event.COMPLETE:
					_status = LazyLoaderStatus.COMPLETE;
					removeInternalHandlers();
					break;
			}
		}
		
		private function removeInternalHandlers():void{
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, internalHandler);
			contentLoaderInfo.removeEventListener(Event.COMPLETE, internalHandler);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			switch(type){
				case Event.COMPLETE:
				case Event.INIT:
				case Event.OPEN:
				case Event.UNLOAD:
				case HTTPStatusEvent.HTTP_STATUS:
				case IOErrorEvent.IO_ERROR:
				case ProgressEvent.PROGRESS:
					contentLoaderInfo.addEventListener(type, dispatchEvent, useCapture, priority, useWeakReference);
					break;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			switch(type){
				case Event.COMPLETE:
				case Event.INIT:
				case Event.OPEN:
				case Event.UNLOAD:
				case HTTPStatusEvent.HTTP_STATUS:
				case IOErrorEvent.IO_ERROR:
				case ProgressEvent.PROGRESS:
					contentLoaderInfo.removeEventListener(type, dispatchEvent, useCapture);
					break;
			}
			super.removeEventListener(type, listener, useCapture);
		}
		
		public function get bytes():ByteArray{ return contentLoaderInfo.bytes; }
		public function get loaded():uint{ return contentLoaderInfo.bytesLoaded; }
		public function get total():uint{ return contentLoaderInfo.bytesTotal; }
		public function get status():String{ return _status; }
		public function get metadata():Object{ return null };
	}
}