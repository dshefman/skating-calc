var numDancers = 0;
var numJudges = 0;
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

function addMarksRow() {
  // Add a row to the marks table. 
  var marksContent = '<tr><td></td>';
  for (var judge = 0; judge < numJudges; judge++) {
    marksContent += '<td><input type="text"></td>';
  }
  marksContent += '</tr>';
  $('#marks table').first().append(marksContent);

  // Set callbacks for new marks table text fields.
  $('#marks tr:last input').focusout(function() {
    generateInter();
  });
}

function addMarksColumn() {
  // Add a column to the marks table. 
  var headerContent = '<th></th>';
  $('#marks tr:first').append(headerContent);
  var markContent = '<td><input type="text"></td>';
  $('#marks tr:gt(0)').append(markContent);

  // Set callbacks for new marks table text fields.
  $('#marks tr:gt(0) td:last-child input').focusout(function() {
    generateInter();
  });
}

function removeMarksColumn() {
  $('#marks th:last').remove();
  $('#marks tr:gt(0) td:last-child').remove();
}

function addDancer() {
  // Add the dancer number/name text input fields.
  var numberInput = '<input type="text" class="numberInput dancer"> ';
  var nameInput = '<input type="text" class="nameInput dancer"> ';
  var lineBreak = '<br class="dancer" />';
  $('#dancerFields').append(numberInput + nameInput + lineBreak);

  // Store the couple index as .data().
  $('#dancerFields .numberInput').eq(numDancers).data('couple', numDancers);

  addMarksRow();

  // Set callback for changing couple number.
  $('#dancerFields .numberInput').eq(numDancers).focusout(function() {
    var trIndex = $.data(this, 'couple') + 1;
    $('#marks tr:eq(' + trIndex + ') td:first').html(this.value);
  });

  numDancers++;

  // Update the inter table's rows and columns. TODO: Temp?
  generateInter();
}

function removeDancer() {
  if (numDancers > 1) {
    // Remove the input fields and the line break.
    var lastKeptIndex = (numDancers - 1) * 3 - 1;
    $('#dancerFields *:gt(' + lastKeptIndex + ')').remove();

    // Remove the last marks row.
    $('#marks tr:last').remove();

    numDancers--;
    
    generateInter();
  }
}

function addJudge() {
  // Add the judge number/name text input fields.
  var numberInput = '<input type="text" class="numberInput judge"> ';
  var nameInput = '<input type="text" class="nameInput judge"> ';
  var lineBreak = '<br class="judge" />';
  $('#judgeFields').append(numberInput + nameInput + lineBreak);

  // Store the judge index as .data().
  $('#judgeFields .numberInput').eq(numJudges).data('judge', numJudges);

  addMarksColumn();

  // Set callback for changing judge number.
  $('#judgeFields .numberInput').eq(numJudges).focusout(function() {
    var thIndex = $.data(this, 'judge') + 1;
    $('#marks tr:first th:eq(' + thIndex + ')').html(this.value);
  });

  numJudges++;
}

function removeJudge() {
  if (numJudges > 1) {
    // Remove the input fields and the linke break.
    var lastKeptIndex = (numJudges - 1) * 3 - 1;
    $('#judgeFields *:gt(' + lastKeptIndex + ')').remove();

    removeMarksColumn();

    numJudges--;

    generateInter();
  }
}

function generateMarks() {
  return;
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
