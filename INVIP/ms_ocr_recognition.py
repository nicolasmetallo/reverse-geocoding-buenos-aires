
# coding: utf-8

# ### NYU Prototyping Fund 2016

# > An ***Electronic Travel Aid*** for indoor navigation aimed at assisting individuals with a visual impairment. It provides: verbal description about their surroundings, face detection, information about location and tactile vibration for obstacle detection.

# **Source:**
# - https://www.microsoft.com/cognitive-services/en-us/computer-vision-api/documentation
# - https://github.com/TusharChugh/SmartCap
# - https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fc

# # OCR recognition
# ----------

# ## Import Libraries
# ----

# In[2]:

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


# ## Variables (Microsoft API)
# ---

# In[3]:

_url_ocr = 'https://api.projectoxford.ai/vision/v1.0/ocr?%s'
_key = 'ec06a13cf3ee490787943f28dd968144'
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

# In[10]:

def exit_gracefully(signum,frame):
    signal.signal(signal.SIGINT, original_sigint)
    sys.exit(1)


# In[ ]:

def txtToMp3(text):

    tts = gTTS(text = text, lang = 'en')
    tts.save('output.mp3')


# In[ ]:

def tts():
    mixer.init()
    mixer.music.load('output.mp3')
    mixer.music.play()


# In[4]:

def processRequest_ocr( json, data, headers, params ):

    retries = 0
    result = None

    while True:

        response = requests.request( 'post', _url_ocr, json = json, data = data, 
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


# In[5]:

def getOCR(data):
    params = urllib.urlencode({'language': 'unk','detectOrientation ': 'true',})
    headers = dict()
    headers['Ocp-Apim-Subscription-Key'] = _key
    headers['Content-Type'] = 'application/octet-stream'

    json = None

    result_ocr = processRequest_ocr(json, data, headers, params) 
    
    if result_ocr is not None:
        
        result = 'I think the text reads: \n'
        for region in result_ocr['regions']:
            for line in region['lines']:
                for word in line['words']:
                    result += word['text'] + ' '
            result += '\n'
        
    return result


# In[7]:

def saveTextFile(text):
    remap = {ord('\t'): ' ', ord('\f'): ' ', ord('\r'): None}
    a = text.translate(remap)
    b = unicodedata.normalize('NFD',a)
    c = b.encode('ascii','ignore').decode('ascii')
    try:
        print(c)
        text_file = open("output_ocr.txt","w+")
        text_file.write(c)
        text_file.close()			 
    except Exception, e:
        print ("Exception occured \n")
        print (e)
        pass


# In[17]:

def run_main():
    # Load raw image file into memory
    hostsvr = ''
    pathToFileInDisk = r'photo_ocr.jpg'
#     pathToFileInDisk = r'' + hostsvr + 'photo.jpg'
    
    with open(pathToFileInDisk, 'rb') as f:
        data = f.read()
        
    #Get the tag
    text = getOCR(data)
    
    #Save the text in the file
    saveTextFile(text)
    
    #Save the text in an mp3 file and play it
    txtToMp3(text)
    tts()


# In[18]:

if __name__ == '__main__':
    original_sigint = signal.getsignal(signal.SIGINT)
    signal.signal(signal.SIGINT,exit_gracefully)
    run_main()


# # ---------------------------------------
