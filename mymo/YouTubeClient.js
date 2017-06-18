window.__mymo = {
  rate: 1
};

var video = null;

function getVideo() {
  return document.getElementsByTagName('video')[0];
}

function playListener() {
  video.playbackRate = window.__mymo.rate;
}

function loadVideo() {
  video = getVideo();
  video.playbackRate = window.__mymo.rate;
  video.removeEventListener('play', playListener);
  video.addEventListener('play', playListener);
}

function changeSpeedRateTo(rate) {
  window.__mymo.rate = rate;
  loadVideo();
}

function rewind() {
  video = getVideo();
  video.currentTime -= 10;
}

function pause() {
  video = getVideo();
  video.pause();
  return video.currentTime;
}

function play() {
  video = getVideo();
  video.play();
}

function seekTo(time) {
  video = getVideo();
  video.currentTime = time;
}

function applyInlinePlay() {
  video = getVideo();
  var attrList = ['webkit-playsinline', 'playsinline', 'controls'];
  attrList.forEach(function(attr) {
    video.setAttribute(attr, '');
  });
}


