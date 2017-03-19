
# coding: utf-8

# # **Project in*VIP***: *Electronic travel guides for the visually impaired*

# ### NYU Prototyping Fund 2016

# > An ***Electronic Travel Aid*** for indoor navigation aimed at assisting individuals with a visual impairment. It provides: verbal description about their surroundings, face detection, information about location and tactile vibration for obstacle detection.

# **Source:**
# - https://www.microsoft.com/cognitive-services/en-us/computer-vision-api/documentation
# - https://github.com/TusharChugh/SmartCap
# - https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fc

# # Face detection
# ----------

# ## Import Libraries
# ----

# In[6]:

# !pip install cognitive_face


# In[7]:

from __future__ import print_function
import time 
import requests
import operator
import numpy as np
import csv
from collections import defaultdict 
import signal
import httplib, urllib, base64
import unicodedata
from pygame import mixer
from gtts import gTTS


# In[8]:

_url = 'https://api.projectoxford.ai/face/v1.0/detect?%s'
_key = 'fbbaa35ed773443cb032380482f96764'
_maxNumRetries = 10


# In[9]:

def txtToMp3(text):
    tts = gTTS(text = text, lang = 'en')
    tts.save('output.mp3')


# In[10]:

def tts():
    mixer.init()
    mixer.music.load('output.mp3')
    mixer.music.play()


# In[11]:

def processRequest( json, data, headers, params ):

    """
    Helper function to process the request to Project Oxford

    Parameters:
    json: Used when processing images from its URL. See API Documentation
    data: Used when processing image read from disk. See API Documentation
    headers: Used to pass the key information and the data type request
    """

    retries = 0
    result = None

    while True:

        response = requests.request( 'post', _url, json = json, data = data, headers = headers, params = params )

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


# In[12]:

def getFace(data):
    params = urllib.urlencode({
        'returnFaceId': 'false',
        'returnFaceLandmarks': 'false',
        'returnFaceAttributes': 'age,gender,smile,glasses',
        })

    headers = dict()
    headers['Ocp-Apim-Subscription-Key'] = _key
    headers['Content-Type'] = 'application/octet-stream'

    json = None

    result = processRequest( json, data, headers, params )
    
    if result is not None:
        num = len(result)
        if num is not 0:
            if num == 1:
                msg = "I think there is {} person in front of you.".format(num)
            elif num > 1: 
                msg = "I think there are {} people in front of you.".format(num)
            res = msg
            for i in range(num):
                age = result[i]['faceAttributes']['age']
                gender = result[i]['faceAttributes']['gender']
                res += ' ' + '{:.0f}'.format(age) + ' years old '+ gender
                if ((num > 1) & (i < (num-2))): res+= ','
                if (i == (num-2)): res+= ' and'
        else: res = "I can't understand what's in front of me"
        
        return res


# In[13]:

def exit_gracefully(signum,frame):
    signal.signal(signal.SIGINT, original_sigint)
    sys.exit(1)


# In[14]:

def saveTextFile(text):
    try:
        print(text)
        text_file = open("output_face.txt","w+")
        text_file.write(text)
        text_file.close()			 
    except Exception, e:
        print ("Exception occured \n")
        print (e)
        pass


# In[15]:

def run_main():
    # Load raw image file into memory
    pathToFileInDisk = r'foto_andres.jpg'
    with open(pathToFileInDisk, 'rb') as f:
        data = f.read()
        
    #Get the tag
    text = getFace(data)
    
    #Save the text in the file
    saveTextFile(text)
    
    #Save the text in an mp3 file and play it
    txtToMp3(text)
    tts()


# In[16]:

if __name__ == '__main__':
    original_sigint = signal.getsignal(signal.SIGINT)
    signal.signal(signal.SIGINT,exit_gracefully)
    run_main()


# # ---------------------------------------
