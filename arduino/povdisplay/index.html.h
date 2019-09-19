const char INDEX_HTML[] PROGMEM = R"=====(
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
    <link rel="icon" href="data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAACMuAAAjLgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAExMTABISEhcMDAw5AAAACQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABsbGwAaGhpRFRUVpAAAABEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAcHBwAGhoaWBYWFrAAAAASAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHBwcABoaGlgWFhawAAAAEQEBAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABwcHAAaGhpYFhYWsAAAABIBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAcHBwAGxsbWBYWFq0AAAAQAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAPAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAFAAAACBASFToREhVgAAAABwEBAQAAAAAAAAAAAAAAAAAAAAAAAAAAggAAADgAAAAiAAAAIgAAABKeZwAPpmwAf5tlAKGcZgCiflMAdQAAAA8AAAAQAAAAHAAAABwAAAAbAAAADAAAAIIAAACwAAAAqgAAAKoAAABNsXMAHcuEANvMhQD/zYYA/6dtALcAAAAdAAAAegAAAKgAAACnAAAAmwAAADUAAACYAAAAvAAAAL8AAAC+AAAAU7J0ABzLhADazIUA/82GAP+nbQC2AAAAHgAAAI0AAAC/AAAAvgAAALAAAAA6AAAASQAAAHIAAAByAAAAcQAAAC++fAAYy4QAyMyFAOzMhQDtr3IAnwAAABQAAABfAAAAfgAAAH0AAABzAAAAIQAAAAAAAAAAAAAAAAAAAADBfgAA248ABJRhADFvSABObUcAUHZNACoAAAABAAAAAAAAAAEAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABEAAAAnwAAAJ8AAAA0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUwAAALoAAAC6AAAAPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFIAAAC6AAAAuQAAADwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABQAAAArwAAAK4AAAAzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/x8AAP8fAAD/HwAA/x8AAP8fAAD/HwAAPB8AAAAAAAAAAAAAAAAAAAAAAAD4EQAA/D8AAPw/AAD8PwAA/D8AAA==">
    <style>
      p
      {
        margin: 0px;
      }
      #list
      {
        width: 500px;
      }
      #source
      {
        width: 500px;
        height : 500px;
        display: flex;
        align-items: center;
        justify-content: center;        
      }
      #video,  #image
      {
        max-width: 500px;
        max-height: 500px;
      }
      #destination
      {
        width: 500px;
        text-align: center;      
      }
      #preview
      {
        width: 500px;
        border-radius: 100%;
      }
      .span40
      {
        display: inline-block;
        width:40px;
      }
      .span100
      {
        display: inline-block;
        width:100px;
      }
      
    </style>
	</head>

	<body>
	<h1>POV Display Interface</h1>
	<div>
    <p>
       Add Files: 
       <input id="input" type="file" accept="image/*,video/*" multiple> 
       <button type="button" id="webcam">Use Webcam</button>  
    </p>
  </div>
	<div>
    <select id="list" size="10">
    </select>  
  </div>
	<div>
    <p>
       <button type="button" id="list_up">Up</button>  
       <button type="button" id="list_down">Down</button>  
       <button type="button" id="list_remove">Remove</button>  
       Auto play: 
       <input type="checkbox" id="auto"> 
       Interval: 
       <select id="interval">
        <option value="1">1s</option>
        <option value="2">2s</option>
        <option value="5" selected>5s</option>
        <option value="10">10s</option>
      </select>      
    </p>
  </div>
  
	<h1>Source</h1>
	<div id="source">
      <img id="logo" src="data:image/jpeg;base64,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" style="display:none" />
      <video id="video" controls autoplay style="display: none"></video>
      <img id="image" src="" style="display: none">
       
  </div>
	<h1>Settings</h1>
  <div>
    <p>
      Frame position: 
      <select id="mode">
        <option value="fill">Fill</option>
        <option value="fita">Fit square</option>
        <option value="fitc">Fit circle</option>
        <option value="stetch">Stetch</option>
      </select> 
    <p>
    </p>
      Set RpS: <span id="rps_set_span"></span>
    <p>
    </p>
      <input type="range" min="50" max="600" value="240" id="rps_set" style="width: 500px;">
    </p>
    </p>
      Set FpS: <span id="fps_set_span"></span>
    <p>
    </p>
      <input type="range" min="50" max="600" value="240" id="fps_set" style="width: 500px;">
    </p>
    </p>
      Set quality: <span id="quality_set_span"></span>
    <p>
    </p>
      <input type="range" min="10" max="100" value="80" id="quality_set" style="width: 500px;">
    </p>
    </p>
  </div>
	<h1>Destination</h1>
  <div id="destination">
    <p>
      <span id="status" class="span100"> OFFLINE</span> 
      RpS: <span id="rps" class="span40"> --</span> 
      <span class="span40"> </span>
      FpS: <span id="fps" class="span40"> --</span>
      <span class="span40"> </span>
      BWT: <span id="mbits" class="span40"> --</span>Mbit/s
    </p>
    <p>
    <span class="span40"> </span>
    </p>
    <canvas id="preview"> </canvas>
  </div>

  
  <script>
    var R=131;
    var URL = window.URL || window.webkitURL;
    Object.defineProperty(HTMLMediaElement.prototype, 'playing', {
        get: function(){
            return !!(this.currentTime > 0 && !this.paused && !this.ended && this.readyState > 2);
        }
    })
    
    var websocket;
    var ws_open= false;
    (function wsConnect(){
      try {
        if(document.location.host==""){
          websocket= new WebSocket("ws://192.168.4.1:8080");
        }
        else{
          websocket= new WebSocket("ws://"+document.location.host+":8080");
        }
      }
      catch(err) {
        console.log(err);
        setTimeout(wsConnect,1000);
      }
      websocket.onopen = function(evt){
        console.log("WS OPEN",evt);
        ws_open=true;
        runframeWorker();
      };
      websocket.onclose= function(evt){
        console.log("WS CLOSE",evt);
        ws_open=false;
        setTimeout(wsConnect,1000);
      };
      websocket.onmessage = function(evt) { 
        if(evt.data.startsWith("STATUS")){
          //read Values
          var status=evt.data.split(":");
          document.querySelector('#rps').innerHTML=status[1]; 
          // send set Values
          console.log("SET:"+rps_set);
          websocket.send("SET:"+rps_set);
        }
        runframeWorker(true);
      };
      websocket.onerror = function(evt) { 
        console.log("WS ERROR",evt);
      };
    })();
    
    function wsSend(data) {
      if(ws_open){
        console.log("Message ",data);
        websocket.send(data);
      }
    }    
    function resetSource(){
      if(document.querySelector('#video').srcObject){
        document.querySelector('#video').srcObject.getTracks().forEach( track => track.stop() );
      }
      document.querySelector('#video').srcObject = undefined;
      document.querySelector('#video').src = "";
      document.querySelector('#video').style.display="none";
      document.querySelector('#video').pause();
      document.querySelector('#image').style.display="none";
    }
    
    document.querySelector('#input').addEventListener('change',function (event){
      for(i=0;i<this.files.length;i++){
        var file=this.files[i];
        var fileURL = URL.createObjectURL(file);
        console.log(file);

        var opt = document.createElement('option');
        opt.appendChild( document.createTextNode(file.name) );
        opt.value = fileURL; 
        opt.setAttribute("type", file.type);
        opt.setAttribute("class", file.type.split("/")[0]);
        document.querySelector('#list').appendChild(opt);         
        
      }
      this.value="";
    });    
    document.querySelector('#webcam').addEventListener('click', function(event){      
      navigator.mediaDevices.getUserMedia({ video: true, audio: false })
      .then(function(stream) {
        console.log(stream);
        resetSource();
        source = document.querySelector('#video');        
        source.srcObject= stream;
        source.style.display="block";
        source_type="video";
        document.querySelector('#list').selectedIndex=-1;
      })
      .catch(function(err) {
          alert("An error occurred: " + err);
      });      
    });
    document.querySelector('#list_up').addEventListener('click', function(event){      
      var index= document.querySelector('#list').selectedIndex;
      if(index<=0) return;
      var option=document.querySelector('#list').selectedOptions[0];
      document.querySelector('#list').remove(index);      
      document.querySelector('#list').add(option,index-1);
    });
    document.querySelector('#list_down').addEventListener('click', function(event){
      var index= document.querySelector('#list').selectedIndex;
      if(index==-1) return;
      var option=document.querySelector('#list').selectedOptions[0];
      document.querySelector('#list').remove(index);
      document.querySelector('#list').add(option,index+1);
    });
    document.querySelector('#list_remove').addEventListener('click', function(event){
      var index= document.querySelector('#list').selectedIndex;
      if(index==-1) return;
      document.querySelector('#list').remove(index);
    });
    
    
    
    
    var source = document.querySelector('#logo');
    var source_type = "image";
    
    document.querySelector('#list').addEventListener('change', function(event)
    {
      resetSource();
      
      if(document.querySelector('#list').selectedIndex==-1) return;

      var option=document.querySelector('#list').selectedOptions[0];
      source_type=option.getAttribute("class");
      switch(source_type) {
        case "video":
          source = document.querySelector('#video');  
          source.src = option.value;
          break;
        case "image":
          source = document.querySelector('#image');  
          source.src = option.value;
          break;
        default:
          source = document.querySelector('#logo');
          source_type="image";
      };
      source.style.display="block";
    });

    (function autoPlay(){
      setTimeout(autoPlay, 1000 * document.querySelector('#interval').value);      
      if(document.querySelector('#auto').checked==false) return;
      switch(source_type) {
        case "video":
          if(document.querySelector('#video').playing) return;
          break;
      };
      console.log("Auto Inrement next!");
      document.querySelector('#list').selectedIndex+=1;
      document.querySelector('#list').dispatchEvent(new Event('change'));
    })();

    var cr = document.createElement("canvas");
    var cp = document.querySelector('#preview');
    cr.height = R;
    cr.width  = R;
    cp.height = R;
    cp.width  = R;
    var ctxr = cr.getContext('2d');
    ctxr.imageSmoothingEnabled = true;
    var ctxp = cp.getContext('2d');
    var imgp = new Image;
    imgp.onload = function(){
      ctxp.drawImage(imgp,0,0); // Or at whatever offset you like
    };
    var ticks=0;
    var bandwith=0;
    var mode ="fill";
    var quality;
    var fps_set;
    var rps_set;
    
    
    var lastframesendtime=0;
    function frameWorker(){
      ctxr.beginPath();
      ctxr.rect(0, 0, R, R);
      ctxr.fillStyle = "black";
      ctxr.fill();
            
      var sw=0;
      var sh=0;
      
      switch(source_type) {
        case "video":
          sw=source.videoWidth;
          sh=source.videoHeight;
          break;
        case "image":
          sw=source.naturalWidth;
          sh=source.naturalHeight;
          break;
      };
      
      
      switch(mode) {
        case "fill":
          if(sw>sh){
            ctxr.drawImage(source, (sw-sh)/2, 0, sh,sh, 0, 0, R, R);
          }
          else
          {
            ctxr.drawImage(source, 0,(sh-sw)/2, sw, sw, 0, 0, R, R);
          }
          break;
        case "fita":
          if(sw>sh){
            ctxr.drawImage(source, 0, -(sw-sh)/2, sw,sw, 0, 0, R, R);
          }
          else
          {
            ctxr.drawImage(source, -(sh-sw)/2, 0, sh,sh, 0, 0, R, R);
          }
          break;
        case "fitc":
          var ratio= sw / sh;
          var length=R/Math.sqrt(Math.pow(ratio,2)+1)
          var x=length*ratio;
          var y=length;
          ctxr.drawImage(source, 0, 0, sw,sh, (R-x)/2, (R-y)/2, x, y);
          break;
        default:
          ctxr.drawImage(source, 0, 0, sw,sh, 0, 0, R, R);
      }       
      
      //get jpeg:
      var image_src= cr.toDataURL("image/jpeg",quality);
      
      imgp.src = image_src;      
      
      //generate blob:
      var arr = image_src.split(',')
      var mime = arr[0].match(/:(.*?);/)[1]
      var bstr = atob(arr[1])
      var n = bstr.length
      var u8arr = new Uint8Array(n);
      while(n--){
          u8arr[n] = bstr.charCodeAt(n);
      }
      var blob = new Blob([u8arr], {type:mime});
      bandwith+= blob.size;
      
      //send data
      wsSend(blob);
      lastframesendtime=window.performance.now();
      
      ticks++;
    }

    //run frame worker
    var lastRunerTimeout;
    var lastWorkerTimeout;
    function runframeWorker(gotok=false){
      // recover in case of packet lost
      clearTimeout(lastRunerTimeout);
      lastRunerTimeout=setTimeout(runframeWorker,1000);      
      var delay=Math.max(0,(1000.0/fps_set)-(window.performance.now()-lastframesendtime));
      clearTimeout(lastWorkerTimeout);
      lastWorkerTimeout=setTimeout(frameWorker,delay);
    };
    
    setInterval(function(){
      //update Mode
      var e =document.querySelector('#mode');
      mode=e.options[e.selectedIndex].value;
      if(ws_open){
        document.querySelector('#status').innerHTML="ONLINE";        
        document.querySelector('#fps').innerHTML=ticks;        
        document.querySelector('#mbits').innerHTML=(bandwith/1024/1024*8).toFixed(2);  
      }
      else{
        document.querySelector('#status').innerHTML="OFFLINE";        
        document.querySelector('#fps').innerHTML="--";        
        document.querySelector('#mbits').innerHTML="--";  
        document.querySelector('#rps').innerHTML="--"
      }

      bandwith=0;
      ticks=0;
      
    }, 1000);
    
    document.querySelector('#rps_set').addEventListener('input',function() {
      rps_set=(this.value/10);
      document.querySelector('#rps_set_span').innerHTML = rps_set.toFixed(1);
    });
    document.querySelector('#fps_set').addEventListener('input',function() {
      fps_set=(this.value/10);
      document.querySelector('#fps_set_span').innerHTML = fps_set.toFixed(1);
    });
    document.querySelector('#quality_set').addEventListener('input',function() {
      quality= document.querySelector('#quality_set').value/100;
      document.querySelector('#quality_set_span').innerHTML = quality.toFixed(2);
    });
    document.querySelector('#rps_set').dispatchEvent(new Event('input'));
    document.querySelector('#fps_set').dispatchEvent(new Event('input'));
    document.querySelector('#quality_set').dispatchEvent(new Event('input'));
        
        
        
  </script>  
	</body>
</html>
)=====";