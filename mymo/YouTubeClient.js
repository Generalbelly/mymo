window.__mymo = {
  rate: 1
};

var video = null;

function getVideo() {
  video = document.getElementsByTagName('video')[0];
  video.removeEventListener('webkitbeginfullscreen', onVideoBeginsFullScreen);
  video.addEventListener('webkitbeginfullscreen', onVideoBeginsFullScreen);
  return video;
}

function playListener() {
  video.playbackRate = window.__mymo.rate;
}

function onVideoBeginsFullScreen() {
  video.webkitExitFullscreen();
  video.pause();
  webkit.messageHandlers.mymo.postMessage(video.currentTime);
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

// opacity: 1;
// filter: none;
// mix-blend-mode: normal;
// border-radius: 0px !important;
// }
// user agent stylesheet
// video:-webkit-full-screen, audio:-webkit-full-screen {
// background-color: transparent;
// position: relative;
// left: 0px;
// top: 0px;
// min-width: 0px;
// max-width: none;
// min-height: 0px;
// max-height: none;
// width: 100%;
// height: 100%;
// display: block;
// transform: none;
// margin: 0px !important;
// flex: 1 1 0% !important;
// }
// user agent stylesheet
// :-webkit-full-screen {
// background-color: white;
// z-index: 2147483647;
