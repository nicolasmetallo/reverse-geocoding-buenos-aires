
# coding: utf-8

# # **Project in*VIP***: *Electronic travel guides for the visually impaired*

# ### NYU Prototyping Fund 2016

# > An ***Electronic Travel Aid*** for indoor navigation aimed at assisting individuals with a visual impairment. It provides: verbal description about their surroundings, face detection, information about location and tactile vibration for obstacle detection.

# **Source:**
# - https://www.microsoft.com/cognitive-services/en-us/computer-vision-api/documentation
# - https://github.com/TusharChugh/SmartCap

# # Feature detection
# ----------

# ## Import Libraries
# ----

# In[34]:

from __future__ import print_function
import time 
import requests
import operator
import numpy as np
import csv
from collections import defaultdict 
import signal
from pygame import mixer
from gtts import gTTS


# ## Variables (Microsoft API)
# ---

# In[35]:

_url_visual = 'https://api.projectoxford.ai/vision/v1.0/analyze'
_key = '6c863d567f2a4a6b94b5fdcb11cc4bf1'
_maxNumRetries = 10


# ### Helper function to process the request to Microsoft API
# ----
# 
# >**Parameters:**
# 
# - **json:** Used when processing images from its URL. See API Documentation
# - **data:** Used when processing image read from disk. See API Documentation
# - **headers:** Used to pass the key information and the data type request<

# To handle the SIGINT when CTRL+C is pressed

# In[36]:

def exit_gracefully(signum,frame):
    signal.signal(signal.SIGINT, original_sigint)
    sys.exit(1)


# In[37]:

def txtToMp3(text):
    tts = gTTS(text = text, lang = 'en')
    tts.save('output.mp3')


# In[38]:

def tts():
    mixer.init()
    mixer.music.load('output.mp3')
    mixer.music.play()


# In[39]:

import httplib, urllib, base64

def processRequest_visual(json, data, headers, params):

    retries = 0
    result = None

    while True:

        response = requests.request( 'post', _url_visual, json = json, data = data, 
                                    headers = headers, params = params )

        if response.status_code == 429: 

            print( "Message: %s" % ( response.json()['error']['message'] ) )

            if retries <= _maxNumRetries: 
                time.sleep(1) 
                retries += 1
                continue
            else: 
                print( 'Error: failed after retrying!' )
                break

        elif response.status_code == 200 or response.status_code == 201:

            if 'content-length' in response.headers and int(response.headers['content-length']) == 0: 
                result = None 
            elif 'content-type' in response.headers and isinstance(response.headers['content-type'], str): 
                if 'application/json' in response.headers['content-type'].lower(): 
                    result = response.json() if response.content else None 
                elif 'image' in response.headers['content-type'].lower(): 
                    result = response.content
        else:
            print( "Error code: %d" % ( response.status_code ) )
            print( "Message: %s" % ( response.json()['error']['message'] ) )

        break
        
    return result


# In[40]:

def getImageTag(data):
    # Computer Vision parameters
    params = {'visualFeatures': 'Description'}

    headers = dict()
    headers['Ocp-Apim-Subscription-Key'] = _key
    headers['Content-Type'] = 'application/octet-stream'

    json = None

    result_visual = processRequest_visual(json, data, headers, params) 
    
    if result_visual is not None:
        data8uint = np.fromstring(data, np.uint8)  # Convert string to an unsigned int array
        print('Got Results !\n')
            #Get the description/tag
        description = result_visual['description']['captions'][0]['text']
        confidence = result_visual['description']['captions'][0]['confidence']
        tags = result_visual['description']['tags']
        print(result_visual,'\n')

        if description is not None:
            columns = defaultdict(list)
        
            if (confidence > 0.9):
                msg = "I am pretty sure it is "
            elif ((confidence > 0.35) & (confidence < 0.9)):
                msg = "I think it is "
            else:
                msg = "I am not sure but I guess it is "

            awsstring = msg
            awsstring += description
        
            if (len(tags) > 1):
                awsstring += ". And the keywords are: "
                num_keywords = 5
                for i in range(num_keywords):
                    awsstring += tags[i]
                    if i != num_keywords - 1:
                        awsstring += ', '
        else:
            awsstring = "I'm sorry but I can't understand what's in front of me"
        
    return awsstring


# In[41]:

#Saves the text to the file                
def saveTextFile(text):
    try:
        print(text)
        text_file = open("output.txt","w+")
        text_file.write(text)
        text_file.close()			 
    except Exception, e:
        print ("Exception occured \n")
        print (e)
        pass 


# In[42]:

def run_main():
    # Load raw image file into memory
    pathToFileInDisk = r'foto_andres.jpg'
    with open(pathToFileInDisk, 'rb') as f:
        data = f.read()
        
    #Get the tag
    text = getImageTag(data)
    
    #Save the text in the file
    saveTextFile(text)
    
    #Save the text in an mp3 file and play it
    txtToMp3(text)
    tts()


# In[43]:

if __name__ == '__main__':
    original_sigint = signal.getsignal(signal.SIGINT)
    signal.signal(signal.SIGINT,exit_gracefully)
    run_main()


# # ---------------------------------------
