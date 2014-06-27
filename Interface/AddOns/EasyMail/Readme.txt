EasyMail by Yarko

Description
-----------
Modifications to the World of Warcraft mail frame.

- For each character, remembers the last addressee to whom mail was sent and defaults that name into the addressee field when a new blank mail is displayed.

- Remembers a user-configurable number of recently-mailed addressees by realm, and allows the player to select from the list to fill in the addressee field by clicking on a drop-down button displayed to the right of the addressee field. If the list is at maximum length, the addressee least recently mailed is removed to add a new addressee. Right-clicking a name in the drop-down list prompts the user to delete that name from the addressee list. The user can manually add a name to the addressee list by clicking the "Add Name" option in the drop-down list. Names added manually are not verified in any way.

- A check box in the options window allows the player to use Blizzard's standard auto-complete functionality. Clearing this check box causes the addressee field to use EasyMail's custom auto-complete functionality.

- Names from the player's friends list and members of the player's guild can be displayed in the addressee drop-down list by setting the appropriate options.

- Automatically fills in the mail subject line if it is empty when entering money to send.

- A Take All button is added to the Open Mail window that allows the player to move all the item and money attachments for the open mail into the player's bags with a single click. This button is disabled on COD mails until the user clicks one item and confirms the COD. The button will not take existing mail text as an attachment. The Take All process will time out if it is unable to take an attachment for 8 seconds.  Closing the mail window will also cancel the process.

- Checkboxes added to the mail inbox allow the user to select mails for attachment retreival. Four graphical buttons added at the top of the inbox allow the user to either mark or clear all mails or mark or clear the mails on the current page. A fifth button starts the get attachments process. COD mails will be ignored until the COD is confirmed manually for each mail by the user. To cancel the attachment retrieval process, close the mailbox.

- Right-click attachment retrieval and mail deletion from the inbox can be enabled using addon options. Right-clicking a mail item with attachments in the inbox will cause the take all process to attempt to retrieve all attachments from the mail. If the mail has text but no attachments, right-clicking will delete the mail. If the mail has both attachments and text, right-clicking will cause the take all to retrieve the attachments. Then, right-clicking again will delete the mail. The right-click does not affect COD mails until after the user chooses to accept the COD manually. The user can opt to disable the deletion prompt for mails marked as read. EasyMail will always prompt on the deletion of unread mails.

- With the proper configuration options set, EasyMail will display mail text in the inbox item tooltip. WARNING: Mails will be immediately marked as read once the tooltip has been displayed. Due to Blizzard's API design, mail text may take a few seconds to appear in the tooltip.

- A Forward button is added to the open mail window. Clicking this button opens a new mail with "FW:" + <subject> copied into the subject line and the text of the open mail body copied into the new mail body. IMPORTANT NOTE: Blizzard's mail system design complicates the automatic forwarding of mail attachments. Therefore, attachments cannot be forwarded using this button at this time. Only the text of the open mail will be copied into the new mail. Attachments must still be moved to the new mail manually. However, this new forwarding functionality makes the process a bit less cumbersome, since the new mail will be visible while you are still viewing the mail with attachments.

- The user is now able to page through the inbox using the mouse wheel.

- Configuration options allow the user to output money amounts and information about attachments being retreived to the chat window for easy post-process review.


Configuration
-------------
Slash commands have been removed. Use the new interface options window to configure EasyMail. Open the main menu, click Interface, click the AddOns tab, and select the EasyMail entry.


Timeout Error Message
---------------------
On occasion, the player might see the error text, "Unable to retrieve an attachment for 10 seconds. Check available bag space or unique items. If you are having internet latency problems, please try the Take All process again at another time." This is a generic error that occurs when the automatic take all process is unable to remove an attachment after trying for 10 seconds. When this happens, the process is canceled. The most likely cause of this error is the player not having enough bag space to store the attachments. The error might also occur if there is significant network lag or if the player does something peculiar with his mail windows while the get all process is running. When the error occurs, make sure the player has enough bag space or waits a bit and then tries the process again.


