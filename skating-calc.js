var numDancers = 1;
var numJudges = 1;
var marks = [];
var inter = [];
var rank = [];

$(function() {
  $('h1').click(function() {
    $(this).hide('slow');
  });

  $('#dancerAdd').click(function() {
    addDancer();
    generateMarks();
  });
  $('#dancerRemove').click(function() {
    removeDancer();
    generateMarks();
  });

  $('#judgeAdd').click(function() {
    addJudge();
    generateMarks();
  });
  $('#judgeRemove').click(function() {
    removeJudge();
    generateMarks();
  });

  $('.numberInput').focusout(function() {
    generateMarks();
  });

  //generateMarks();
});

function addDancer() {
  numDancers++;
  var numberInput = '<input type="text" class="numberInput dancer" id="dancerNumber' + numDancers + '"> ';
  var nameInput = '<input type="text" class="nameInput dancer" id="dancerName' + numDancers + '"> ';
  var lineBreak = '<br class="dancer" />';
  $('#dancerFields').append(numberInput + nameInput + lineBreak);

  //$('.numberInput').focusout(function() {
    //generateMarks();
  //});
  $('#dancerFields .numberInput:gt(' + (numDancers - 2) + ')').data('couple', numDancers - 1);

  $('#dancerFields .numberInput:gt(' + (numDancers - 2) + ')').focusout(function() {
    console.log('hi ' + $.data(this, 'couple'));
  });
}

function removeDancer() {
  if (numDancers > 1) {
    var firstIndexDeleted = (numDancers - 1) * 3 - 1;
    $('.dancer:gt(' + firstIndexDeleted + ')').remove();
    numDancers--;
  }
}

function addJudge() {
  numJudges++;
  var numberInput = '<input type="text" class="numberInput judge" id="judgeNumber' + numJudges + '"> ';
  var nameInput = '<input type="text" class="nameInput judge" id="judgeName' + numJudges + '"> ';
  var lineBreak = '<br class="judge" />';
  $('#judgeFields').append(numberInput + nameInput + lineBreak);

  $('.numberInput').focusout(function() {
    generateMarks();
  });
}

function removeJudge() {
  if (numJudges > 1) {
    var firstIndexDeleted = (numJudges - 1) * 3 - 1;
    $('.judge:gt(' + firstIndexDeleted + ')').remove();
    numJudges--;
  }
}

function generateMarks() {
  var content = '<table><tr><th></th>';
  $('.numberInput.judge').each(function() {
    content += '<th>' + this.value + '</th>';
  });
  content += '</tr>';
  $('.numberInput.dancer').each(function() {
    content += '<tr><td>' 
    content += this.value;
    content += '</td>';
    for (var i = 0; i < numJudges; i++) {
      content += '<td><input type="text"></td>';
    }
    content += '</tr>';
  });
  content += '</table>';
  $('#marks').html(content);

  //console.log('inputs: ' + $('#marks input').length);
  generateInter();
  $('#marks input').focusout(function() {
    generateInter();
  });
}

function markCount(couple, mark) {
  var count = 0;
  for (var i = 0; i < numJudges; i++) {
    if (marks[couple][i] == mark) {
      //console.log('found ' + marks[couple][i]);
      count++;
    }
  }
  //console.log('count, couple, mark ' + count + ', ' + couple + ', ' + mark);
  return count;
}

function sortedMajority(positionArray, rank, majorityScore) {
  majority = [];
  for (var i = 0; i < positionArray.length; i++) {
    if (rank[i] == -1 && positionArray[i] >= majorityScore) {
      var index = majority.length;
      majority[index] = { couple: i, total: positionArray[i] };
      for (var j = index - 1; j >= 0 && majority[j].total < majority[j + 1].total; j--) {
        var tmp = majority[j];
        majority[j] = majority[j + 1];
        majority[j + 1] = tmp;
      }
    }
  }
  //console.log('majority ret ' + majority);
  return majority;
}

function generateInter() {
  // Save marks.
  raw_marks = $('#marks input');
  marks = [];
  for (var i = 0; i < numDancers; i++) {
    marks[i] = [];
    for (var j = 0; j < numJudges; j++) {
      marks[i][j] = parseInt(raw_marks[i * numJudges + j].value);
      //console.log('couple, judge, mark ' + i + ', ' + j + ', ' + marks[i][j]);
    }
  }

  var majority = numJudges / 2 + 1;
  var currentPlace = 1;
  var goodCouples = [];
  for (var i = 0; i < numDancers; i++) {
    goodCouples[i] = true;
    rank[i] = -1;
  }
  inter = [];
  if (numDancers > 0) {
    inter[0] = [];
    for (var couple = 0; couple < numDancers; couple++) {
      inter[0][couple] = markCount(couple, 1);
    }
    scoringCouples = sortedMajority(inter[0], rank, majority);
    for (var i = 0; i < scoringCouples.length; i++) {
      rank[scoringCouples[i].couple] = currentPlace++;
    }
    //for (var i = 0; i < numDancers; i++) {
      //if (rank[i] == -1 && inter[0][i] >= majority) {
        //rank[i] = currentPlace++;
      //}
    //}
  }
  for (var position = 1; position < numDancers; position++) {
    inter[position] = [];
    for (var couple = 0; couple < numDancers; couple++) {
      inter[position][couple] = inter[position - 1][couple] + markCount(couple, position + 1);
    }
    scoringCouples = sortedMajority(inter[position], rank, majority);
    for (var i = 0; i < scoringCouples.length; i++) {
      rank[scoringCouples[i].couple] = currentPlace++;
    }
    //for (var i = 0; i < numDancers; i++) {
     // if (rank[i] == -1 && inter[position][i] >= majority) {
      //  rank[i] = currentPlace++;
      //}
    //}
  }

  var content = '<table><tr>';
  if (numDancers > 0) {
    content += '<th>1</th>';
  }
  for (var i = 1; i < numDancers; i++) {
    content += '<th>1 - ' + (i + 1) + '</th>';
  }
  content += '<th>Rank</th>';
  content += '</tr>';

  for (var i = 0; i < numDancers; i++) {
    content += '<tr>';
    for (var j = 0; j < numDancers; j++) {
      content += '<td>' + inter[j][i] + '</td>';
    }
    content += '<td>' + rank[i] + '</td>';
    content += '</tr>';
  }
  content += '</table>';
  $('#inter').html(content);
}
