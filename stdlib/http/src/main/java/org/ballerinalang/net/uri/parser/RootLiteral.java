package org.ballerinalang.net.uri.parser;

import org.ballerinalang.net.uri.URITemplateException;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

public class RootLiteral <DataType, InboundMsgType> extends Literal<DataType, InboundMsgType> {
    private int tokenLength = 0;

    public RootLiteral(DataElement<DataType, InboundMsgType> dataElement, String token) throws URITemplateException {
        super(dataElement, token);
        tokenLength = token.length();
        if (tokenLength == 0) {
            throw new URITemplateException("Invalid literal token with zero length");
        }
    }

    @Override
    int match(String uriFragment, Map<String, String> variables) {
        if (!token.endsWith("*")) {
            try {
                uriFragment = URLDecoder.decode(uriFragment, StandardCharsets.UTF_8.name());
            } catch (UnsupportedEncodingException e) {
                throw new RuntimeException("Error while decoding value: " + uriFragment, e);
            }
            if (uriFragment.length() < tokenLength) {
                return -1;
            }
            for (int i = 0; i < tokenLength; i++) {
                if (token.charAt(i) != uriFragment.charAt(i)) {
                    if (token.charAt(i) == '*' && i == token.length() - 1) {
                        return uriFragment.length();
                    }
                    return -1;
                }
            }
            //special case request urls which contains only the root("/") to be dispatched to default resource("/*").
            if (uriFragment.equals("/") && uriFragment.equals(token) && !this.dataElement.hasData()) {
                return 0;
            }
//            String encodedToken = null;
//            try {
//                encodedToken = URLEncoder.encode(token, StandardCharsets.UTF_8.name());
//            } catch (UnsupportedEncodingException e) {
//                throw new RuntimeException("Error while decoding value: " + encodedToken, e);
//            }
//
//            return encodedToken.length();
            return tokenLength;
        } else {
            if (uriFragment.length() < tokenLength - 1) {
                return -1;
            }
            for (int i = 0; i < tokenLength - 1; i++) {
                if (token.charAt(i) != uriFragment.charAt(i)) {
                    if (i == token.length() - 1) {
                        return uriFragment.length();
                    }
                    return -1;
                }
            }
            return uriFragment.length();
        }
    }
}
