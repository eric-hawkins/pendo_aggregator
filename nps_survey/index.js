function recordAnalytics(success, eventData) {
      eventData["success"] = success
      eventData["acctId"] = eventData["accountId"]
      PropertyNewRelicInsights.addEvent("NPSPendoSync", {data: eventData})
    }
function sendData(accountId, contactId, score, comments) {
      npsData = {
          "accountId": accountId,
          "contactId": contactId,
          "score": score,
          "scoreExplanation": comments
        }
      $.ajax({
        url: "https://appfolio.secure.force.com/npssurvey/services/apexrest/survey/",
        data: JSON.stringify(npsData),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        type: "PUT",
        dataType: "json",
        success: function (data) {
          if (data.includes('Salesforce could not')) {
            npsData["errorResp"] = data
            recordAnalytics("false", npsData)
          } else {
            npsData["survey"] = data
            recordAnalytics("true", npsData)
          }
        },
        error: function (jqXHR, status, error) {
          npsData["status"] = jqXHR.status
          npsData["statusText"] = jqXHR.statusText
          npsData["errorResp"] = jqXHR.responseJSON[0].message
          recordAnalytics("false", npsData)
        }
      });
    }
$('#nps_poll_submit').on('click', function() {
    var $submitButton = $(this);
    setTimeout(function() {
        $submitButton.closest('._pendo-guide-container_').find('._pendo-close-guide_').trigger('click');
    }, 1000);
    var selectedNPS = $('._pendo-poll-npsrating-choices_ input:checked').val();
    var npsComments = $('#nps_poll_comments').val();
    var contactId = document.getElementsByClassName("_pendo-hidden-item_")[0].innerHTML
    var accountId = document.getElementsByClassName("_pendo-hidden-item_")[1].innerHTML
    //var contactId = pendo.visitorId
    //var accountId = pendo.accountId

    sendData(accountId, contactId, selectedNPS, npsComments);
});
